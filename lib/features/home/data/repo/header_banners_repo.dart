import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/home/data/datasources/local/database/header_banners_database_service.dart';
import 'package:nowdelivery_user_app/features/home/data/datasources/remote/api/header_banners_api_service.dart';




class HeaderBannersRepo {
  final HeaderBannersApiService _apiService = HeaderBannersApiService();
  final HeaderBannersDatabaseService _databaseService =
      HeaderBannersDatabaseService();

  void cancelRequests() => _apiService.cancelRequests();






  Future<Either<Failure, List<BannerModel>>> getHeaderBanners() async {


    final Either<Failure, Map<String, dynamic>> serverResult =
        await _fetchFromServer();

    return serverResult.fold(

      (Failure serverFailure) => _readFromCache(serverFailure),

      (Map<String, dynamic> data) async {
        await _cacheHeaderBanners(data);
        return Right<Failure, List<BannerModel>>(_parseBanners(data));
      },
    );
  }


  Future<Either<Failure, Map<String, dynamic>>> _fetchFromServer() async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _apiService.getHeaderBanners();

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      return Right(body['data'] as Map<String, dynamic>);
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody =
          data is Map<String, dynamic> ? data : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (exception) {
      return Left(Failure(exception.toString()));
    }
  }



  Future<void> _cacheHeaderBanners(Map<String, dynamic> data) async {
    try {
      await _databaseService.saveHeaderBanners(jsonEncode(data));
    } catch (_) {

    }
  }



  Future<Either<Failure, List<BannerModel>>> _readFromCache(
    Failure serverFailure,
  ) async {
    try {
      final String? cached = _databaseService.getHeaderBanners();
      if (cached == null) {
        return Left<Failure, List<BannerModel>>(serverFailure);
      }

      final Map<String, dynamic> data =
          jsonDecode(cached) as Map<String, dynamic>;
      return Right<Failure, List<BannerModel>>(_parseBanners(data));
    } catch (_) {
      return Left<Failure, List<BannerModel>>(serverFailure);
    }
  }



  List<BannerModel> _parseBanners(Map<String, dynamic> data) {
    final List<dynamic> rawBanners =
        data['banners'] as List<dynamic>? ?? <dynamic>[];
    return rawBanners
        .whereType<Map<String, dynamic>>()
        .map(BannerModel.fromJson)
        .toList();
  }
}
