import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/features/promotion/data/datasources/local/welcome_voucher_cache_service.dart';
import 'package:nowdelivery_user_app/features/promotion/data/datasources/remote/api/promotion_api_service.dart';






class PromotionRepo {
  final PromotionApiService _promotionApiService = PromotionApiService();
  final WelcomeVoucherCacheService _welcomeVoucherCacheService =
      WelcomeVoucherCacheService();

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







  Future<Either<Failure, CouponModel>> getCoupon(String code) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _promotionApiService.getCoupon(code);

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data =
          body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final Map<String, dynamic>? couponJson =
          data['coupon'] as Map<String, dynamic>?;

      if (couponJson == null) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      return Right(CouponModel.fromJson(couponJson));
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody =
          data is Map<String, dynamic> ? data : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (exception) {
      return Left(Failure(exception.toString()));
    }
  }







  Future<Either<Failure, CouponModel>> getWelcomeVoucher(String code) async {
    final Either<Failure, CouponModel> serverResult = await getCoupon(code);

    return serverResult.fold(

      (Failure serverFailure) => _readWelcomeCodeFromCache(serverFailure),

      (CouponModel coupon) async {
        final String? freshCode = coupon.code;
        if (freshCode != null && freshCode.isNotEmpty) {
          await _cacheWelcomeCode(freshCode);
        }
        return Right<Failure, CouponModel>(coupon);
      },
    );
  }

  Future<void> _cacheWelcomeCode(String code) async {
    try {
      await _welcomeVoucherCacheService.saveWelcomeCode(code);
    } catch (_) {

    }
  }

  Either<Failure, CouponModel> _readWelcomeCodeFromCache(
    Failure serverFailure,
  ) {
    final String? cached = _welcomeVoucherCacheService.getWelcomeCode();
    if (cached == null || cached.isEmpty) {
      return Left(serverFailure);
    }
    return Right(CouponModel(code: cached));
  }
}
