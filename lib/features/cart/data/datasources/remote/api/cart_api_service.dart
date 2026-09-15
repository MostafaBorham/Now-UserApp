import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/cart/data/datasources/remote/api/cart_endpoints.dart';









class CartApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();


  void cancelRequests() => _canceller.cancel();




  Future<Response> getCart() {
    return _dio.get(CartEndpoints.getCart, cancelToken: _canceller.token);
  }




  Future<Response> deleteCartProduct(int productId) {
    return _dio.patch(
      CartEndpoints.cartProduct(productId),
      data: CartEndpoints.quantityBody(0),
      cancelToken: _canceller.token,
    );
  }




  Future<Response> deleteCartVendorItem(int vendorId) {
    return _dio.delete(
      CartEndpoints.cartVendor(vendorId),
      cancelToken: _canceller.token,
    );
  }



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
