import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/features/products/data/datasources/remote/api/products_endpoints.dart';

/// Raw API calls for the categories feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer).
class ProductsApiService {
  final Dio _dio = DioFactory.getDio();

  Future<Response> getProducts({int? categoryId}) {
    ProductsEndpoints.categoryId = categoryId;
    return _dio.get(
      ProductsEndpoints.getProducts,
      queryParameters: ProductsEndpoints.getProductsQuery,
    );
  }
}