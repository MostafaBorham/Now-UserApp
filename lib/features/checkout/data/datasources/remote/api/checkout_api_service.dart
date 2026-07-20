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

  /// Drafts an order group for every store in the cart (sends a `null`
  /// `vendor_id`). Authentication is applied by `AuthTokenInterceptor` from the
  /// cached session.
  Future<Response> checkoutForAllStores() {
    return _dio.post(
      CheckoutEndpoints.checkout,
      data: CheckoutEndpoints.checkoutBody(),
      cancelToken: _canceller.token,
    );
  }

  /// Drafts an order group for a single store identified by [vendorId].
  /// Authentication is applied by `AuthTokenInterceptor` from the cached
  /// session.
  Future<Response> checkoutForSingleStore(int vendorId) {
    return _dio.post(
      CheckoutEndpoints.checkout,
      data: CheckoutEndpoints.checkoutBody(vendorId: vendorId),
      cancelToken: _canceller.token,
    );
  }
}
