import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
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
  /// returned; on failure it falls back to the cached copy in Hive, and only
  /// surfaces the original failure when nothing has been cached yet.
  Future<Either<Failure, PersonalInformationData>> getProfile() async {
    final Either<Failure, Map<String, dynamic>> serverResult =
        await _fetch(_api.getProfile);

    return serverResult.fold(
      (Failure serverFailure) => _readFromCache(serverFailure),
      (Map<String, dynamic> data) async {
        await _cache(data);
        return Right<Failure, PersonalInformationData>(_parse(data));
      },
    );
  }

  /// Persists the edited [body] (from [ProfileModel.toUpdateJson]) — text only,
  /// via PUT + JSON — refreshes the cache, and returns the updated profile.
  Future<Either<Failure, PersonalInformationData>> updateProfile(
    Map<String, dynamic> body,
  ) {
    return _sendUpdate(() => _api.updateProfile(body));
  }

  /// Persists text [fields] together with an avatar change (a new [avatar] file
  /// or [removeAvatar]) via POST + multipart. [fields] must already exclude
  /// nulls — multipart can't carry them.
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
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final int statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      return Right(body['data'] as Map<String, dynamic>);
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (_) {
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }

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
