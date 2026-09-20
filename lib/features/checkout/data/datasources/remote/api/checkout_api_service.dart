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

  /// Drafts a single-store checkout preview scoped to [vendorId] via the
  /// `POST /api/v1/checkout/vendor/{vendorId}/preview` endpoint. Authentication
  /// is applied by `AuthTokenInterceptor` from the cached session.
  Future<Response> checkoutForSingleStore({required int vendorId}) {
    return _dio.post(
      CheckoutEndpoints.checkoutForSingleStore(vendorId),
      cancelToken: _canceller.token,
    );
  }

  /// Applies coupon [code] for [vendorId] and returns the per-vendor discount
  /// calculation. Stateless — the server reads the user's own cart.
  /// Authentication is applied by `AuthTokenInterceptor` from the cached
  /// session.
  Future<Response> applyCoupon({required int vendorId, required String code}) {
    return _dio.post(
      CheckoutEndpoints.couponsApply,
      data: CheckoutEndpoints.discountApplyBody(vendorId: vendorId, code: code),
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

  /// Confirms the draft order group identified by [orderGroupUuid] — the final
  /// checkout step, submitting the delivery address, driver tip, notes, payment
  /// method and coupons together. Authentication is applied by
  /// `AuthTokenInterceptor` from the cached session.
  Future<Response> confirmOrder({
    required String orderGroupUuid,
    required String idempotencyKey,
    int? addressId,
    String? paymentMethod,
    int? paymentMethodId,
    double? driverTip,
    String? notes,
    String? deliveryInstructions,
    Map<int, String>? coupons,
  }) {
    return _dio.post(
      CheckoutEndpoints.confirmOrder(orderGroupUuid),
      data: CheckoutEndpoints.confirmOrderBody(
        addressId: addressId,
        paymentMethod: paymentMethod,
        paymentMethodId: paymentMethodId,
        driverTip: driverTip,
        notes: notes,
        deliveryInstructions: deliveryInstructions,
        coupons: coupons,
      ),
      // Placing is the one non-idempotent step: the server dedupes retries by
      // this per-request key (same key + same body → replays the placed order),
      // so it must be reused across retries of the same submit and rotated when
      // the order changes. See the checkout screen for that lifecycle.
      options: Options(headers: <String, dynamic>{
        'Idempotency-Key': idempotencyKey,
      }),
      cancelToken: _canceller.token,
    );
  }
}
