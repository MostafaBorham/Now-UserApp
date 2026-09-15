import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/categories/data/datasources/remote/api/categories_endpoints.dart';









class CategoriesApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();


  void cancelRequests() => _canceller.cancel();

  Future<Response> getAppCategories({required int page, String? search}) {
    return _dio.get(
      CategoriesEndpoints.getAppCategories,
      queryParameters: CategoriesEndpoints.appCategoriesQuery(
        page,
        search: search,
      ),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getCategoryStores({
    required String categorySlug,
    required int? categoryId,
    required int page,
    String? search,
  }) {
    return _dio.get(
      CategoriesEndpoints.categoryStores(categorySlug),
      queryParameters: CategoriesEndpoints.categoryStoresQuery(
        page: page,
        categoryId: categoryId,
        search: search,
      ),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getCategoryProducts({
    required String categorySlug,
    required int? categoryId,
    required int page,
    String? search,
  }) {
    return _dio.get(
      CategoriesEndpoints.categoryProducts(categorySlug),
      queryParameters: CategoriesEndpoints.categoryProductsQuery(
        page: page,
        categoryId: categoryId,
        search: search,
      ),
      cancelToken: _canceller.token,
    );
  }
}
