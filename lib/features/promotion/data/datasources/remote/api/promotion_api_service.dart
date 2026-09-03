import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/promotion/data/datasources/remote/api/promotion_endpoints.dart';

/// Raw API calls for the promotion feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer).
///
/// Cancellation is fully encapsulated here: every request carries the token
/// of [_canceller], and callers only see the plain [cancelRequests] method.
class PromotionApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  Future<Response> getCoupons({required int page}) {
    PromotionEndpoints.page = page;
    return _dio.get(
      PromotionEndpoints.coupons,
      queryParameters: PromotionEndpoints.getCouponsQuery,
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getCoupon(String code) {
    return _dio.get(
      PromotionEndpoints.couponByCode(code),
      cancelToken: _canceller.token,
    );
  }
}
