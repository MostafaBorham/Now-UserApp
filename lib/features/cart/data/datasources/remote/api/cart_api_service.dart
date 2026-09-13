import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/cart/data/datasources/remote/api/cart_endpoints.dart';

/// Raw API calls for the cart feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer).
///
/// Cancellation is fully encapsulated here: every request carries the token
/// of [_canceller], and callers only see the plain [cancelRequests] method.
class CartApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  /// Fetches the current user's cart. Authentication is handled entirely by
  /// `AuthTokenInterceptor`, which attaches the right header (`Bearer` for a
  /// logged-in user, `X-Guest-Token` for a guest) from the cached session.
  Future<Response> getCart() {
    return _dio.get(CartEndpoints.getCart, cancelToken: _canceller.token);
  }

  /// Removes the cart line for [productId] by sending the `{"quantity": 0}`
  /// payload the endpoint expects. Authentication is applied by
  /// `AuthTokenInterceptor` from the cached session.
  Future<Response> deleteCartProduct(int productId) {
    return _dio.patch(
      CartEndpoints.cartProduct(productId),
      data: CartEndpoints.quantityBody(0),
      cancelToken: _canceller.token,
    );
  }

  /// Removes every cart line belonging to [vendorId] in one request. The server
  /// answers with the fresh cart. Authentication is applied by
  /// `AuthTokenInterceptor` from the cached session.
  Future<Response> deleteCartVendorItem(int vendorId) {
    return _dio.delete(
      CartEndpoints.cartVendor(vendorId),
      cancelToken: _canceller.token,
    );
  }

  /// Sets the cart line for [productId] to [quantity]. Authentication is applied
  /// by `AuthTokenInterceptor` from the cached session.
  Future<Response> updateCartProductQuantity(int productId, int quantity) {
    return _dio.patch(
      CartEndpoints.cartProduct(productId),
      data: CartEndpoints.quantityBody(quantity),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> addToCart(int productId, int quantity) {
    return _dio.post(
      CartEndpoints.addToCart,
      data: CartEndpoints.addToCartBody(quantity, productId),
      cancelToken: _canceller.token,
    );
  }
}
