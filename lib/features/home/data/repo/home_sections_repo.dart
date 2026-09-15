import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/home/data/datasources/local/database/home_sections_database_service.dart';
import 'package:nowdelivery_user_app/features/home/data/datasources/remote/api/home_sections_api_service.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';




class HomeSectionsRepo {
  final HomeSectionsApiService _apiService = HomeSectionsApiService();
  final HomeSectionsDatabaseService _databaseService =
      HomeSectionsDatabaseService();

  void cancelRequests() => _apiService.cancelRequests();









  Future<Either<Failure, List<HomeSectionModel>>> getHomeSections({
    required String platform,
    required String lang,
    double? lat,
    double? lng,
  }) async {


    final Either<Failure, Map<String, dynamic>> serverResult =
        await _fetchFromServer(
          platform: platform,
          lang: lang,
          lat: lat,
          lng: lng,
        );

    return serverResult.fold(

      (Failure serverFailure) => _readFromCache(serverFailure),

      (Map<String, dynamic> data) async {
        await _cacheHomeSections(data);
        return Right<Failure, List<HomeSectionModel>>(_parseSections(data));
      },
    );
  }


  Future<Either<Failure, Map<String, dynamic>>> _fetchFromServer({
    required String platform,
    required String lang,
    double? lat,
    double? lng,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _apiService.getHomeSections(
        platform: platform,
        lang: lang,
        lat: lat,
        lng: lng,
      );

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








  Future<void> _cacheHomeSections(Map<String, dynamic> data) async {
    try {
      await _databaseService.saveHomeSections(jsonEncode(data));
    } catch (_) {

    }
  }



  Future<Either<Failure, List<HomeSectionModel>>> _readFromCache(
    Failure serverFailure,
  ) async {
    try {
      final String? cached = _databaseService.getHomeSections();
      if (cached == null) {
        return Left<Failure, List<HomeSectionModel>>(serverFailure);
      }

      final Map<String, dynamic> data =
          jsonDecode(cached) as Map<String, dynamic>;
      return Right<Failure, List<HomeSectionModel>>(_parseSections(data));
    } catch (_) {
      return Left<Failure, List<HomeSectionModel>>(serverFailure);
    }
  }



  List<HomeSectionModel> _parseSections(Map<String, dynamic> data) {
    final List<dynamic> rawSections =
        data['sections'] as List<dynamic>? ?? <dynamic>[];
    return rawSections
        .whereType<Map<String, dynamic>>()
        .map(HomeSectionModel.fromJson)
        .toList();
  }
}
