import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/network/dio_factory.dart';
import 'package:nowdelivery_user_app/core/network/endpoints.dart';

/// Raw API calls for the categories feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer).
class CategoriesApiService {
  final Dio _dio = DioFactory.getDio();

  Future<Response> getCategories() {
    return _dio.get(Endpoints.getCategoriesEndpoint,);
  }
}
