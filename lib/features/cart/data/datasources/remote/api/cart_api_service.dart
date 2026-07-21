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
    return _dio.get(
      CartEndpoints.getCart,
      cancelToken: _canceller.token,
    );
  }

  /// Removes the cart line for [productId]. The body is always the static
  /// `{"quantity": 0}` payload the endpoint expects. Authentication is applied
  /// by `AuthTokenInterceptor` from the cached session.
  Future<Response> updateCartProduct(int productId,int? productQuantity) {
    CartEndpoints.productQuantity = productQuantity??0;
    return _dio.delete(
      CartEndpoints.cartProduct(productId),
      data: CartEndpoints.updateQuantityToCartProductBody,
      cancelToken: _canceller.token,
    );
  }
}
