import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/checkout/data/datasources/remote/api/checkout_endpoints.dart';

/// Raw API calls for the checkout feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer).
///
/// Cancellation is fully encapsulated here: every request carries the token
/// of [_canceller], and callers only see the plain [cancelRequests] method.
class CheckoutApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  /// Drafts an order group. A `null` [vendorId] drafts every store in the cart;
  /// a concrete [vendorId] drafts only that single store. Authentication is
  /// applied by `AuthTokenInterceptor` from the cached session.
  Future<Response> checkout({int? vendorId}) {
    return _dio.post(
      CheckoutEndpoints.checkout,
      data: CheckoutEndpoints.checkoutBody(vendorId: vendorId),
      cancelToken: _canceller.token,
    );
  }

  /// Applies [coupons] (vendor id → coupon code) to the draft order group
  /// identified by [orderGroupUuid] and returns the refreshed draft, which has
  /// the same shape as [checkout]. Authentication is applied by
  /// `AuthTokenInterceptor` from the cached session.
  Future<Response> applyCoupons({
    required String orderGroupUuid,
    required Map<int, String> coupons,
  }) {
    return _dio.post(
      CheckoutEndpoints.draftCoupons(orderGroupUuid),
      data: CheckoutEndpoints.draftCouponsBody(coupons: coupons),
      cancelToken: _canceller.token,
    );
  }
}
