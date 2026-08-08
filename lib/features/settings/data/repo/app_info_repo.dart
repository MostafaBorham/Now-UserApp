import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/settings/data/datasources/local/database/app_info_database_service.dart';
import 'package:nowdelivery_user_app/features/settings/data/datasources/remote/api/app_info_api_service.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/app_info_model.dart';

class AppInfoRepo {
  final AppInfoApiService _appInfoApiService = AppInfoApiService();
  final AppInfoDatabaseService _appInfoDatabaseService =
      AppInfoDatabaseService();

  void cancelRequests() => _appInfoApiService.cancelRequests();

  Future<Either<Failure, AppInfoModel>> getAppInfo() async {
    final Either<Failure, AppInfoModel> serverResult = await _fetchFromServer();

    return serverResult.fold(
      // Server failed → fall back to the cache.
      (Failure serverFailure) => _readFromCache(serverFailure),
      // Server succeeded → persist the fresh data, then return it.
      (AppInfoModel appInfo) async {
        await _cacheAppInfo(appInfo);
        return Right<Failure, AppInfoModel>(appInfo);
      },
    );
  }

  Future<Either<Failure, AppInfoModel>> _fetchFromServer() async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _appInfoApiService.getAppInfo();
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      return Right(AppInfoModel.fromJson(data));
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (exception) {
      return Left(Failure(exception.toString()));
    }
  }


  Future<void> _cacheAppInfo(AppInfoModel appInfo) async {
    try {
      await _appInfoDatabaseService.saveAppInfo(jsonEncode(appInfo.toJson()));
    } catch (_) {
      // Intentionally ignored — caching is a side effect, not part of the result.
    }
  }


  Future<Either<Failure, AppInfoModel>> _readFromCache(
    Failure serverFailure,
  ) async {
    try {
      final String? cached = _appInfoDatabaseService.getAppInfo();
      if (cached == null) {
        return Left(serverFailure);
      }

      final Map<String, dynamic> data =
          jsonDecode(cached) as Map<String, dynamic>;
      return Right(AppInfoModel.fromJson(data));
    } catch (_) {
      return Left(serverFailure);
    }
  }
}