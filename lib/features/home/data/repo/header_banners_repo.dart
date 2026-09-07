import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/home/data/datasources/remote/api/header_banners_api_service.dart';

/// Data operations for the home header banners. Returns `Either<Failure, T>`:
/// `Left` carries a user-facing message (a [LangKeys] key or a raw server
/// message — callers apply `.tr()`, which leaves non-key strings untouched).
class HeaderBannersRepo {
  final HeaderBannersApiService _apiService = HeaderBannersApiService();

  void cancelRequests() => _apiService.cancelRequests();

  /// The published `header_main_page` banners. An empty list is valid (the
  /// admin has published no header banners yet).
  Future<Either<Failure, List<BannerModel>>> getHeaderBanners() async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _apiService.getHeaderBanners();

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final List<dynamic> rawBanners =
          data['banners'] as List<dynamic>? ?? <dynamic>[];

      final List<BannerModel> banners = rawBanners
          .whereType<Map<String, dynamic>>()
          .map(BannerModel.fromJson)
          .toList();

      return Right(banners);
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
