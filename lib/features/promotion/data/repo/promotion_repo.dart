import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/dio/api_response.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/features/promotion/data/datasources/local/welcome_voucher_cache_service.dart';
import 'package:nowdelivery_user_app/features/promotion/data/datasources/remote/api/promotion_api_service.dart';

/// All data operations of the promotion feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a raw server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
class PromotionRepo {
  /// [api] and [isConnected] are injectable for tests, as in `CartRepo`.
  PromotionRepo({
    PromotionApiService? api,
    Future<bool> Function()? isConnected,
  }) : _promotionApiService = api ?? PromotionApiService(),
       _isConnected = isConnected ?? (() => ConnectionChecker.isConnected);

  final PromotionApiService _promotionApiService;
  final Future<bool> Function() _isConnected;
  final WelcomeVoucherCacheService _welcomeVoucherCacheService =
      WelcomeVoucherCacheService();

  void cancelRequests() => _promotionApiService.cancelRequests();

  Future<Either<Failure, PaginationModel<CouponModel>>> getCoupons({
    required int page,
  }) async {
    if (!await _isConnected()) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _promotionApiService.getCoupons(page: page);

      return readApiResponse(response).map((Map<String, dynamic> body) {
        final Map<String, dynamic> data = responseData(body);

        final Map<String, dynamic> paginationData =
            data['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};
        final List<dynamic> rawCoupons =
            data['coupons'] as List<dynamic>? ?? <dynamic>[];

        final List<CouponModel> coupons = rawCoupons
            .whereType<Map<String, dynamic>>()
            .map(CouponModel.fromJson)
            .toList();

        return PaginationModel<CouponModel>.fromJson(paginationData, coupons);
      });
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody =
          data is Map<String, dynamic> ? data : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (_) {
      // A parse error's text is a Dart type error, not a message for the
      // customer.
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }

  /// Fetches a single coupon by its [code] from `GET /api/v1/coupons/{code}`.
  ///
  /// The endpoint is public (no auth) and returns `{ data: { coupon: {…} } }`.
  /// A missing/inactive/non-public code answers 404, which surfaces here as a
  /// [Left] — callers (the welcome-voucher banner) treat any [Left] as "don't
  /// show".
  Future<Either<Failure, CouponModel>> getCoupon(String code) async {
    if (!await _isConnected()) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _promotionApiService.getCoupon(code);

      return readApiResponse(response).flatMap((Map<String, dynamic> body) {
        final Map<String, dynamic> data = responseData(body);
        final Map<String, dynamic>? couponJson =
            data['coupon'] as Map<String, dynamic>?;

        if (couponJson == null) {
          return Left<Failure, CouponModel>(
            Failure(ApiErrorHandler.extractErrorMessage(body)),
          );
        }

        return Right<Failure, CouponModel>(CouponModel.fromJson(couponJson));
      });
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody =
          data is Map<String, dynamic> ? data : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (_) {
      // A parse error's text is a Dart type error, not a message for the
      // customer.
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }

  /// The first-order welcome voucher, server-first with an offline cache.
  ///
  /// Offline, the cached code — reconstructed into a [CouponModel] carrying
  /// just the code — stands in, and the failure surfaces only when the cache is
  /// empty. Online, the server's answer stands: on success the fresh code is
  /// persisted (best-effort); on a failure the cache is cleared. Falling back
  /// on *any* failure kept a code the admin had deactivated (a 404) on screen
  /// for good (BUG-022).
  /// ponytail: every online failure clears it, not only a 404 — the cache only
  /// serves offline starts, and the next successful fetch restores it.
  Future<Either<Failure, CouponModel>> getWelcomeVoucher(String code) async {
    if (!await _isConnected()) {
      return _readWelcomeCodeFromCache(
        const Failure(LangKeys.noInternetConnectionKey),
      );
    }

    final Either<Failure, CouponModel> serverResult = await getCoupon(code);

    return serverResult.fold(
      (Failure serverFailure) async {
        await _forgetWelcomeCode();
        return Left<Failure, CouponModel>(serverFailure);
      },
      // Server succeeded → persist the fresh code, then return the coupon.
      (CouponModel coupon) async {
        final String? freshCode = coupon.code;
        if (freshCode != null && freshCode.isNotEmpty) {
          await _cacheWelcomeCode(freshCode);
        }
        return Right<Failure, CouponModel>(coupon);
      },
    );
  }

  Future<void> _forgetWelcomeCode() async {
    try {
      await _welcomeVoucherCacheService.clearWelcomeCode();
    } catch (_) {
      // Ignored, like the save: the cache is a side effect.
    }
  }

  Future<void> _cacheWelcomeCode(String code) async {
    try {
      await _welcomeVoucherCacheService.saveWelcomeCode(code);
    } catch (_) {
      // Intentionally ignored — caching is a side effect, not part of the result.
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
