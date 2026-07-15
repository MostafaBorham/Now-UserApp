import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/categories/data/datasources/remote/api/categories_endpoints.dart';

/// Raw API calls for the categories feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer).
///
/// Cancellation is fully encapsulated here: every request carries the token
/// of [_canceller], and callers only see the plain [cancelRequests] method.
class CategoriesApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  Future<Response> getAppCategories() {
    return _dio.get(
      CategoriesEndpoints.getAppCategories,
      queryParameters: CategoriesEndpoints.getAppCategoriesQuery,
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getProductSubCategories() {
    return _dio.get(
      CategoriesEndpoints.getProductSubCategories,
      queryParameters: CategoriesEndpoints.getProductSubCategoriesQuery,
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getStoreSubCategories() {
    return _dio.get(
      CategoriesEndpoints.getStoreSubCategories,
      queryParameters: CategoriesEndpoints.getStoreSubCategoriesQuery,
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getCategoryStores({required String categorySlug, required int? categoryId}) {
    CategoriesEndpoints.appCategorySlug = categorySlug;
    CategoriesEndpoints.categoryId = categoryId;
    return _dio.get(
      CategoriesEndpoints.getCategoryStores,
      queryParameters: CategoriesEndpoints.getCategoryStoresQuery,
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getCategoryProducts({required String categorySlug,required int? categoryId}) {
    CategoriesEndpoints.appCategorySlug = categorySlug;
    CategoriesEndpoints.categoryId = categoryId;
    return _dio.get(
      CategoriesEndpoints.getCategoryProducts,
      queryParameters: CategoriesEndpoints.getCategoryProductsQuery,
      cancelToken: _canceller.token,
    );
  }
}
