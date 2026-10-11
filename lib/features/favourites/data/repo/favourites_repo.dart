import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/dio/api_response.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/favourites/data/datasources/remote/api/favourites_api_service.dart';
import 'package:nowdelivery_user_app/features/favourites/data/models/favourite_category_model.dart';

/// All data operations of the favourites feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a raw server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
class FavouritesRepo {
  final FavouritesApiService _favouritesApiService = FavouritesApiService();

  /// Cancels every in-flight request of this repo. The actual cancellation
  /// mechanism (CancelToken) lives entirely inside the data source layer.
  void cancelRequests() => _favouritesApiService.cancelRequests();

  /// One page of favourited products. Each favourite wraps the product under
  /// `favoritable`, returned with the full storefront card contract, so it maps
  /// straight onto [ProductModel] and reuses the catalogue product card.
  Future<Either<Failure, PaginationModel<ProductModel>>> getFavouriteProducts({
    required int page,
    String? search,
    List<int>? categoryIds,
    String? sort,
  }) {
    return _guard(
      () => _favouritesApiService.getFavourites(
        type: 'product',
        page: page,
        search: search,
        categoryIds: categoryIds,
        sort: sort,
      ),
      (data) => _paginated(data, ProductModel.fromJson),
    );
  }

  /// One page of favourited stores. Same shape as [getFavouriteProducts], with
  /// the `favoritable` carrying the store card contract → [StoreModel].
  Future<Either<Failure, PaginationModel<StoreModel>>> getFavouriteStores({
    required int page,
    String? search,
    List<int>? categoryIds,
    String? sort,
  }) {
    return _guard(
      () => _favouritesApiService.getFavourites(
        type: 'vendor',
        page: page,
        search: search,
        categoryIds: categoryIds,
        sort: sort,
      ),
      (data) => _paginated(data, StoreModel.fromJson),
    );
  }

  /// The category chip row for a tab (`product` / `vendor`).
  Future<Either<Failure, List<FavouriteCategoryModel>>> getFavouriteCategories({
    required String type,
  }) {
    return _guard(
      () => _favouritesApiService.getFavouriteCategories(type: type),
      (data) => (data['categories'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(FavouriteCategoryModel.fromJson)
          .toList(),
    );
  }

  /// Turns a `{favorites: [{favoritable: {...}}], pagination: {...}}` payload
  /// into a [PaginationModel] of the favourited targets. A favourite whose
  /// target went missing (`favoritable` null) is skipped rather than faked.
  PaginationModel<T> _paginated<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic> favoritable) fromFavoritable,
  ) {
    final Map<String, dynamic> pagination =
        data['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> rawFavourites =
        data['favorites'] as List<dynamic>? ?? <dynamic>[];

    final List<T> items = rawFavourites
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> favourite) => favourite['favoritable'])
        .whereType<Map<String, dynamic>>()
        .map(fromFavoritable)
        .toList();

    return PaginationModel<T>.fromJson(pagination, items);
  }

  /// Shared request envelope: connection check, non-200 handling, and
  /// Dio/exception mapping, so each method only describes its own [parse].
  Future<Either<Failure, T>> _guard<T>(
    Future<Response> Function() request,
    T Function(Map<String, dynamic> data) parse,
  ) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await request();
      return readApiResponse(response).map(
        (Map<String, dynamic> body) =>
            parse(responseData(body)),
      );
    } on DioException catch (exception) {
      return Left(Failure(ApiErrorHandler.messageForDio(exception)));
    } catch (_) {
      return const Left(Failure(LangKeys.somethingWentWrongKey));
    }
  }

  Future<Either<Failure, void>> addProductToFavourites({
    required int productId,
  }) =>
      _mutation(
        () => _favouritesApiService.addProductToFavourites(productId: productId),
      );

  Future<Either<Failure, void>> addStoreToFavourites({required int storeId}) =>
      _mutation(
        () => _favouritesApiService.addStoreToFavourites(storeId: storeId),
      );

  Future<Either<Failure, void>> removeProductFromFavourites({
    required int productId,
  }) =>
      _mutation(
        () => _favouritesApiService.removeProductFromFavourites(
          productId: productId,
        ),
      );

  Future<Either<Failure, void>> removeStoreFromFavourites({
    required int storeId,
  }) =>
      _mutation(
        () => _favouritesApiService.removeStoreFromFavourites(storeId: storeId),
      );

  /// Shared envelope for the add/remove mutations. Success is any 2xx — the
  /// body is not required, so a `204 No Content` (or any empty/non-map body) is
  /// still a success rather than a cast failure. Only failures need a body, and
  /// a missing or non-map one degrades to a localized default message; the
  /// unexpected-error path returns a localized key rather than a raw Dart error.
  Future<Either<Failure, void>> _mutation(
    Future<Response> Function() request,
  ) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await request();
      final int status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) return const Right(null);

      final dynamic body = response.data;
      return Left(
        Failure(
          ApiErrorHandler.extractErrorMessage(
            body is Map<String, dynamic> ? body : null,
          ),
        ),
      );
    } on DioException catch (exception) {
      return Left(Failure(ApiErrorHandler.messageForDio(exception)));
    } catch (_) {
      return const Left(Failure(LangKeys.somethingWentWrongKey));
    }
  }
}
