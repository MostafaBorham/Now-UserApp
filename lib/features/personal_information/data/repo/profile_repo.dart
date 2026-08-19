import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/datasources/remote/api/profile_api_service.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/personal_information_data.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';

/// Data operations for the personal_information feature.
///
/// Every method returns `Either<Failure, T>`; the connection check and error
/// mapping live in [_guard]. The repo also orchestrates assembling the
/// screen's [PersonalInformationData] so the view stays presentational.
class ProfileRepo {
  final ProfileApiService _api = ProfileApiService();

  void cancelRequests() => _api.cancelRequests();

  /// Fetches the authenticated user's profile and wraps it in the screen state.
  /// Avatar is deferred, so `avatarUrl` is left null.
  Future<Either<Failure, PersonalInformationData>> getProfile() {
    return _guard(_api.getProfile, (data) {
      final Map<String, dynamic>? user = data['user'] as Map<String, dynamic>?;
      return PersonalInformationData(
        profile: ProfileModel.fromJson(user),
        avatarUrl: user?['avatar_url']?.toString(),
      );
    });
  }

  /// Persists the edited [body] (from [ProfileModel.toUpdateJson]) — text only,
  /// via PUT + JSON — and returns the updated profile.
  Future<Either<Failure, ProfileModel>> updateProfile(
    Map<String, dynamic> body,
  ) {
    return _guard(() => _api.updateProfile(body), _parseUser);
  }

  /// Persists text [fields] together with an avatar change (a new [avatar] file
  /// or [removeAvatar]) via POST + multipart. [fields] must already exclude
  /// nulls — multipart can't carry them.
  Future<Either<Failure, ProfileModel>> updateProfileWithMedia({
    required Map<String, dynamic> fields,
    File? avatar,
    bool removeAvatar = false,
  }) {
    return _guard(
      () => _api.updateProfileMultipart(
        fields: fields,
        avatar: avatar,
        removeAvatar: removeAvatar,
      ),
      _parseUser,
    );
  }

  /// The update response mirrors the GET envelope; parse the nested `user`
  /// when present, otherwise the `data` map itself.
  ProfileModel _parseUser(Map<String, dynamic> data) {
    final dynamic user = data['user'];
    return ProfileModel.fromJson(user is Map<String, dynamic> ? user : data);
  }

  /// Shared request envelope: connection check, non-2xx handling, and
  /// Dio/exception mapping, so each method only describes its own [parse].
  /// Any 2xx counts as success, not just 200 — the avatar POST answers 201.
  Future<Either<Failure, T>> _guard<T>(
    Future<Response> Function() request,
    T Function(Map<String, dynamic> data) parse,
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

      return Right(parse(body['data'] as Map<String, dynamic>));
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
}
