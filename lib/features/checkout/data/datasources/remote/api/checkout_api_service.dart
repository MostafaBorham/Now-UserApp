import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/checkout/data/datasources/remote/api/checkout_endpoints.dart';

/// Raw API calls for the checkout feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer). Authentication is applied by `AuthTokenInterceptor`
/// from the cached session.
///
/// Cancellation is fully encapsulated here: every request carries the token
/// of [_canceller], and callers only see the plain [cancelRequests] method.
class CheckoutApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  /// Prices the checkout of [vendorId] (`null` = the whole cart) with the
  /// choices in [body] (see [CheckoutEndpoints.pricingBody]).
  Future<Response> preview({
    int? vendorId,
    Map<String, dynamic> body = const <String, dynamic>{},
  }) {
    return _dio.post(
      CheckoutEndpoints.preview(vendorId),
      data: body,
      cancelToken: _canceller.token,
    );
  }

  /// Applies coupon [code] for [vendorId], delivered to [addressId], and
  /// returns the per-vendor discount calculation. Stateless — the server reads
  /// the user's own cart.
  Future<Response> applyCoupon({
    required int vendorId,
    required String code,
    int? addressId,
  }) {
    return _dio.post(
      CheckoutEndpoints.couponsApply,
      data: CheckoutEndpoints.discountApplyBody(
        vendorId: vendorId,
        code: code,
        addressId: addressId,
      ),
      cancelToken: _canceller.token,
    );
  }

  /// Applies purchase-voucher [code] for [vendorId]. Same request/response
  /// shape as [applyCoupon].
  Future<Response> applyPurchaseVoucher({
    required int vendorId,
    required String code,
  }) {
    return _dio.post(
      CheckoutEndpoints.purchaseVouchersApply,
      data: CheckoutEndpoints.discountApplyBody(vendorId: vendorId, code: code),
      cancelToken: _canceller.token,
    );
  }

  /// Places the order for [vendorId] (`null` = the whole cart) with [body]
  /// (see [CheckoutEndpoints.placeBody]).
  Future<Response> placeOrder({
    int? vendorId,
    required String idempotencyKey,
    required Map<String, dynamic> body,
  }) {
    return _dio.post(
      CheckoutEndpoints.place(vendorId),
      data: body,
      // Placing is the one non-idempotent step: the server dedupes retries by
      // this per-request key (same key + same body → replays the placed order),
      // so it must be reused across retries of the same submit and rotated when
      // the order changes. See `ConfirmOrderViewModel` for that lifecycle.
      options: Options(headers: <String, dynamic>{
        'Idempotency-Key': idempotencyKey,
      }),
      cancelToken: _canceller.token,
    );
  }
}
