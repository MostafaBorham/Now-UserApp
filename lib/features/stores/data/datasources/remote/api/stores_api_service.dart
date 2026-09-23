import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/stores/data/datasources/remote/api/stores_endpoints.dart';

/// Raw API calls for the stores feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer).
///
/// Cancellation is fully encapsulated here: every request carries the token
/// of [_canceller], and callers only see the plain [cancelRequests] method.
class StoresApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  Future<Response> getStores({
    required int page,
    String? search,
    int? categoryId,
    String? rating,
  }) {
    return _dio.get(
      StoresEndpoints.getStores,
      queryParameters: StoresEndpoints.storesQuery(
        page: page,
        search: search,
        categoryId: categoryId,
        rating: rating,
      ),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getFeaturedStores({required int page}) {
    return _dio.get(
      StoresEndpoints.getFeaturedStores,
      queryParameters: <String, dynamic>{'page': page},
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getStoreDetails({required int storeId}) {
    return _dio.get(
      StoresEndpoints.storeDetails(storeId),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getStoreProducts({
    required int storeId,
    required int? categoryId,
    required String filter,
    required int page,
    String? search,
  }) {
    return _dio.get(
      StoresEndpoints.storeProducts(storeId),
      queryParameters: StoresEndpoints.storeProductsQuery(
        page: page,
        filter: filter,
        categoryId: categoryId,
        search: search,
      ),
      // Serialize `category_ids` as `category_ids[]=1` — the bracketed form
      // Laravel parses into an array.
      options: Options(listFormat: ListFormat.multiCompatible),
      cancelToken: _canceller.token,
    );
  }
}
