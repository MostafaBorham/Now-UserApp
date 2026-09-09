import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/home/data/datasources/remote/api/home_sections_api_service.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';

/// Data operations of the home feed. Returns `Either<Failure, T>`: `Left`
/// carries a user-facing message (a [LangKeys] key or a raw server message —
/// callers apply `.tr()`, which leaves non-key strings untouched).
class HomeSectionsRepo {
  final HomeSectionsApiService _apiService = HomeSectionsApiService();

  void cancelRequests() => _apiService.cancelRequests();

  /// The ordered, published home sections. An empty list is valid (the admin
  /// has not published a feed yet).
  ///
  /// [lat] / [lng] locate the `nearby_stores` section for a guest; see
  /// [HomeSectionsApiService.getHomeSections].
  Future<Either<Failure, List<HomeSectionModel>>> getHomeSections({
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

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final List<dynamic> rawSections =
          data['sections'] as List<dynamic>? ?? <dynamic>[];

      final List<HomeSectionModel> sections = rawSections
          .whereType<Map<String, dynamic>>()
          .map(HomeSectionModel.fromJson)
          .toList();

      return Right(sections);
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody =
          data is Map<String, dynamic> ? data : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (exception) {
      return Left(Failure(exception.toString()));
    }
  }
}
