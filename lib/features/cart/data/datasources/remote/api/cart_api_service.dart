import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/cart/data/datasources/remote/api/cart_endpoints.dart';

/// Raw cart requests. Parsing and error handling belong to [CartRepo].
class CartApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  void cancelRequests() => _canceller.cancel();

  Future<Response> getCart() {
    return _dio.get(CartEndpoints.getCart, cancelToken: _canceller.token);
  }

  Future<Response> deleteCartVendorItem(int vendorId) {
    return _dio.delete(
      CartEndpoints.cartVendor(vendorId),
      cancelToken: _canceller.token,
    );
  }

  /// Sets a cart line to [quantity]; a `quantity` of `0` removes it — there is
  /// no separate delete endpoint for a single line. [cartItemId] picks which
  /// line of the product to change when it is in the cart as several variants.
  Future<Response> updateCartProductQuantity(
    int productId,
    int quantity, {
    int? cartItemId,
  }) {
    return _dio.patch(
      CartEndpoints.cartProduct(productId),
      data: CartEndpoints.quantityBody(quantity),
      queryParameters: CartEndpoints.cartItemQuery(cartItemId),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> addToCart(
    int productId,
    int quantity,
    Map<String, dynamic>? options,
  ) {
    return _dio.post(
      CartEndpoints.addToCart,
      data: CartEndpoints.addToCartBody(quantity, productId, options),
      cancelToken: _canceller.token,
    );
  }
}
