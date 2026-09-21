import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/products/data/datasources/remote/api/products_endpoints.dart';









class ProductsApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();


  void cancelRequests() => _canceller.cancel();

  Future<Response> getProducts({String? search}) {
    return _dio.get(
      ProductsEndpoints.getProducts,
      queryParameters: ProductsEndpoints.getProductsQuery(search: search),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getProductDetails({required String productSlug}) {
    return _dio.get(
      ProductsEndpoints.productDetails(productSlug),
      cancelToken: _canceller.token,
    );
  }
}
