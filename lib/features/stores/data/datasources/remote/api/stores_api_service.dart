import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/features/stores/data/datasources/remote/api/stores_endpoints.dart';

/// Raw API calls for the stores feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer).
class StoresApiService {
  final Dio _dio = DioFactory.getDio();

  Future<Response> getStoreDetails({required int storeId}) {
    StoresEndpoints.storeId = storeId;
    return _dio.get(
      StoresEndpoints.getStoreDetails,
    );
  }
}
