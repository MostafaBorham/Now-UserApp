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

  /// One page of the caller's favourites of [type] (`product` / `vendor`),
  /// optionally filtered by [search] / [categoryIds] and ordered by [sort].
  Future<Response> getFavourites({
    required String type,
    required int page,
    String? search,
    List<int>? categoryIds,
    String? sort,
  }) {
    return _dio.get(
      FavouritesEndpoints.getFavourites,
      queryParameters: FavouritesEndpoints.getFavouritesQuery(
        type: type,
        page: page,
        search: search,
        categoryIds: categoryIds,
        sort: sort,
      ),
      // Serialize `category_ids` as `category_ids[]=1&category_ids[]=2` — the
      // bracketed form Laravel parses into an array.
      options: Options(listFormat: ListFormat.multiCompatible),
      cancelToken: _canceller.token,
    );
  }

  /// The category chip row for [type] (`product` / `vendor`).
  Future<Response> getFavouriteCategories({required String type}) {
    return _dio.get(
      FavouritesEndpoints.getFavouriteCategories,
      queryParameters: FavouritesEndpoints.getFavouriteCategoriesQuery(
        type: type,
      ),
      cancelToken: _canceller.token,
    );
  }

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

  Future<Response> removeProductFromFavourites({required int productId}) {
    return _dio.delete(
      FavouritesEndpoints.removeProductFromFavourites(productId: productId),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> removeStoreFromFavourites({required int storeId}) {
    return _dio.delete(
      FavouritesEndpoints.removeStoreFromFavourites(storeId: storeId),
      cancelToken: _canceller.token,
    );
  }
}
