import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/dio/api_response.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/datasources/local/database/profile_database_service.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/datasources/remote/api/profile_api_service.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/personal_information_data.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';

/// Data operations for the personal_information feature.
///
/// Every method returns `Either<Failure, T>`. The connection check and error
/// mapping live in [_fetch]; parsing the server envelope into the screen's
/// [PersonalInformationData] lives in [_parse] so the view stays presentational.
///
/// The signed-in user's profile is mirrored into a Hive box: [getProfile]
/// always tries the server first, caches a fresh copy on success, and falls
/// back to the last cached copy when the server is unreachable. Successful
/// updates refresh that same cache so the local copy never drifts.
class ProfileRepo {
  final ProfileApiService _api = ProfileApiService();
  final ProfileDatabaseService _db = ProfileDatabaseService();

  void cancelRequests() => _api.cancelRequests();

  /// Fetches the authenticated user's profile.
  ///
  /// Always tries the server first: on success the fresh payload is cached and
  /// returned; when the device is offline it falls back to the cached copy in
  /// Hive, and only surfaces the original failure when nothing has been cached.
  ///
  /// The fall-back is deliberately limited to *connectivity* failures. A 401
  /// whose refresh failed, or a 4xx/5xx, means the server rejected us — showing
  /// a cached profile there hides a session that has actually ended, and leaves
  /// the user looking at a record they may no longer own.
  Future<Either<Failure, PersonalInformationData>> getProfile() async {
    final Either<Failure, Map<String, dynamic>> serverResult =
        await _fetch(_api.getProfile);

    return serverResult.fold(
      (Failure serverFailure) => _isUnreachable(serverFailure)
          ? _readFromCache(serverFailure)
          : Future<Either<Failure, PersonalInformationData>>.value(
              Left<Failure, PersonalInformationData>(serverFailure),
            ),
      (Map<String, dynamic> data) async {
        await _cache(data);
        return Right<Failure, PersonalInformationData>(_parse(data));
      },
    );
  }

  /// Persists the edited [body] (from [ProfileModel.changesFrom]) — text only,
  /// via PUT + JSON — refreshes the cache, and returns the updated profile.
  Future<Either<Failure, PersonalInformationData>> updateProfile(
    Map<String, dynamic> body,
  ) {
    return _sendUpdate(() => _api.updateProfile(body));
  }

  /// Persists text [fields] together with an avatar change (a new [avatar] file
  /// or [removeAvatar]) via POST + multipart. [fields] is the same diff the JSON
  /// path sends, nulls included — dio renders a null field as an empty string,
  /// which the backend reads back as null.
  Future<Either<Failure, PersonalInformationData>> updateProfileWithMedia({
    required Map<String, dynamic> fields,
    File? avatar,
    bool removeAvatar = false,
  }) {
    return _sendUpdate(
      () => _api.updateProfileMultipart(
        fields: fields,
        avatar: avatar,
        removeAvatar: removeAvatar,
      ),
    );
  }

  /// Runs a write request: on success caches the fresh payload and returns the
  /// parsed profile. Unlike [getProfile] there is no cache fall-back — a failed
  /// write must surface as a failure, not silently return a stale copy.
  Future<Either<Failure, PersonalInformationData>> _sendUpdate(
    Future<Response> Function() request,
  ) async {
    final Either<Failure, Map<String, dynamic>> result = await _fetch(request);

    return result.fold(
      (Failure failure) => Left<Failure, PersonalInformationData>(failure),
      (Map<String, dynamic> data) async {
        await _cache(data);
        return Right<Failure, PersonalInformationData>(_parse(data));
      },
    );
  }

  /// Shared request envelope: connection check, non-2xx handling and
  /// Dio/exception mapping. Returns the raw server `data` map on success so the
  /// caller can both cache it verbatim and parse it. Any 2xx counts as success,
  /// not just 200 — the avatar POST answers 201.
  Future<Either<Failure, Map<String, dynamic>>> _fetch(
    Future<Response> Function() request,
  ) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await request();
      return readApiResponse(response).map(
        (Map<String, dynamic> body) =>
            responseData(body),
      );
    } on DioException catch (exception) {
      final Response<dynamic>? response = exception.response;

      // No response at all means we never reached the server (DNS, timeout,
      // connection dropped, request cancelled). That is a different failure from
      // one the server answered with, and only this kind may fall back to cache
      // — so it gets its own key rather than `ApiErrorHandler`'s generic one.
      if (response == null) {
        return const Left(Failure(LangKeys.serverConnectionFailedKey));
      }

      final dynamic data = response.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (_) {
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }

  /// Whether [failure] means we never got an answer from the server, as opposed
  /// to an answer we did not like. Only the former may be served from cache.
  bool _isUnreachable(Failure failure) =>
      failure.message == LangKeys.noInternetConnectionKey ||
      failure.message == LangKeys.serverConnectionFailedKey;

  /// Assembles the screen state from a raw server (or cached) `data` envelope.
  PersonalInformationData _parse(Map<String, dynamic> data) {
    final Map<String, dynamic>? user = data['user'] as Map<String, dynamic>?;
    return PersonalInformationData(
      profile: ProfileModel.fromJson(user),
      avatarUrl: user?['avatar_url']?.toString(),
    );
  }

  /// Persists [data] verbatim. Caching is a side effect, never part of the
  /// result, so any failure here is swallowed.
  Future<void> _cache(Map<String, dynamic> data) async {
    try {
      await _db.saveProfile(jsonEncode(data));
    } catch (_) {}
  }

  /// Falls back to the cached payload, surfacing [serverFailure] only when there
  /// is nothing cached (or the cached copy can't be read).
  Future<Either<Failure, PersonalInformationData>> _readFromCache(
    Failure serverFailure,
  ) async {
    try {
      final String? cached = _db.getProfile();
      if (cached == null) return Left(serverFailure);

      final Map<String, dynamic> data =
          jsonDecode(cached) as Map<String, dynamic>;
      return Right(_parse(data));
    } catch (_) {
      return Left(serverFailure);
    }
  }
}
