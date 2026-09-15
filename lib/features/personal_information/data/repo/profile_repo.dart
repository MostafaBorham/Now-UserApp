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











class ProfileRepo {
  final ProfileApiService _api = ProfileApiService();
  final ProfileDatabaseService _db = ProfileDatabaseService();

  void cancelRequests() => _api.cancelRequests();











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



  Future<Either<Failure, PersonalInformationData>> updateProfile(
    Map<String, dynamic> body,
  ) {
    return _sendUpdate(() => _api.updateProfile(body));
  }





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
      final Response<dynamic>? response = exception.response;






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



  bool _isUnreachable(Failure failure) =>
      failure.message == LangKeys.noInternetConnectionKey ||
      failure.message == LangKeys.serverConnectionFailedKey;


  PersonalInformationData _parse(Map<String, dynamic> data) {
    final Map<String, dynamic>? user = data['user'] as Map<String, dynamic>?;
    return PersonalInformationData(
      profile: ProfileModel.fromJson(user),
      avatarUrl: user?['avatar_url']?.toString(),
    );
  }



  Future<void> _cache(Map<String, dynamic> data) async {
    try {
      await _db.saveProfile(jsonEncode(data));
    } catch (_) {}
  }



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
