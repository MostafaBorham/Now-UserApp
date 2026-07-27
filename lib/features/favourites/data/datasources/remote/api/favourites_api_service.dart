import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/favourites/data/datasources/remote/api/favourites_endpoints.dart';

/// Raw API calls for the favourites feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer).
///
/// Cancellation is fully encapsulated here: every request carries the token
/// of [_canceller], and callers only see the plain [cancelRequests] method.
class FavouritesApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  Future<Response> addProductToFavourites({required int productId}) {
    return _dio.post(
      FavouritesEndpoints.addToFavourites,
      data: FavouritesEndpoints.addProductToFavouritesBody(
        productId: productId,
      ),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> addStoreToFavourites({required int storeId}) {
    return _dio.post(
      FavouritesEndpoints.addToFavourites,
      data: FavouritesEndpoints.addStoreToFavouritesBody(
        storeId: storeId
      ),
      cancelToken: _canceller.token,
    );
  }
}
