import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/products/data/datasources/remote/api/products_endpoints.dart';

/// Raw API calls for the products feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer).
///
/// Cancellation is fully encapsulated here: every request carries the token
/// of [_canceller], and callers only see the plain [cancelRequests] method.
class ProductsApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  Future<Response> getProducts({int? categoryId}) {
    ProductsEndpoints.categoryId = categoryId;
    return _dio.get(
      ProductsEndpoints.getProducts,
      queryParameters: ProductsEndpoints.getProductsQuery,
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getProductDetails({required String productSlug}) {
    ProductsEndpoints.productSlug = productSlug;
    return _dio.get(
      ProductsEndpoints.getProductDetails,
      cancelToken: _canceller.token,
    );
  }
}