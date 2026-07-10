import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/features/categories/data/datasources/remote/api/categories_endpoints.dart';

/// Raw API calls for the categories feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer).
class CategoriesApiService {
  final Dio _dio = DioFactory.getDio();

  Future<Response> getCategories() {
    return _dio.get(
      CategoriesEndpoints.getCategories,
      queryParameters: CategoriesEndpoints.getCategoriesQuery,
    );
  }
}
