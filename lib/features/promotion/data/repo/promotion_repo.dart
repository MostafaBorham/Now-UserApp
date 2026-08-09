import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/features/promotion/data/datasources/remote/api/promotion_api_service.dart';

/// All data operations of the promotion feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a raw server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
class PromotionRepo {
  final PromotionApiService _promotionApiService = PromotionApiService();
  void cancelRequests() => _promotionApiService.cancelRequests();

  Future<Either<Failure, PaginationModel<CouponModel>>> getCoupons({
    required int page,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _promotionApiService.getCoupons(page: page);

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data =
          body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final Map<String, dynamic> paginationData =
          data['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final List<dynamic> rawCoupons =
          data['coupons'] as List<dynamic>? ?? <dynamic>[];

      final List<CouponModel> coupons = rawCoupons
          .map((dynamic e) => CouponModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(
        PaginationModel<CouponModel>.fromJson(paginationData, coupons),
      );
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
