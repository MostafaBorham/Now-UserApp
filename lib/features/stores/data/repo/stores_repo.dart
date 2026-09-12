import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/stores/data/datasources/local/database/featured_stores_database_service.dart';
import 'package:nowdelivery_user_app/features/stores/data/datasources/remote/api/stores_api_service.dart';

/// All data operations of the stores feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a raw server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
class StoresRepo {
  final StoresApiService _storesApiService = StoresApiService();
  final FeaturedStoresDatabaseService _featuredStoresDatabaseService =
      FeaturedStoresDatabaseService();

  /// Cancels every in-flight request of this repo. The actual cancellation
  /// mechanism (CancelToken) lives entirely inside the data source layer.
  void cancelRequests() => _storesApiService.cancelRequests();

  /// The "Best brands" featured stores, one page at a time (the home carousel
  /// takes the first few; the top-brands screen pages through the rest).
  ///
  /// Server-first with a local (Hive) fallback: a successful **first-page**
  /// fetch refreshes the cache so the local copy tracks the server, and when the
  /// server is unreachable the first page is served from the cache instead.
  /// Later pages have no cached copy and simply surface the server failure.
  Future<Either<Failure, PaginationModel<StoreModel>>> getFeaturedStores({
    required int page,
  }) async {
    // Fetch the raw server `data` object so it can be both cached verbatim and
    // parsed — the cache round-trips through the same parsing the server uses.
    final Either<Failure, Map<String, dynamic>> serverResult =
        await _fetchFeaturedStores(page);

    return serverResult.fold(
      // Server failed → fall back to the cached first page.
      (Failure serverFailure) =>
          _readFeaturedStoresFromCache(page, serverFailure),
      // Server succeeded → refresh the cache (first page only), then parse.
      (Map<String, dynamic> data) async {
        if (page == PaginatedViewModel.firstPageNumber) {
          await _cacheFeaturedStores(data);
        }
        return Right<Failure, PaginationModel<StoreModel>>(
          _parseFeaturedStores(data),
        );
      },
    );
  }

  /// Runs the guarded featured-stores request and returns the raw server `data`
  /// object.
  Future<Either<Failure, Map<String, dynamic>>> _fetchFeaturedStores(
    int page,
  ) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _storesApiService.getFeaturedStores(
        page: page,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      return Right(body['data'] as Map<String, dynamic>);
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (exception) {
      return Left(Failure(exception.toString()));
    }
  }

  /// Persists the raw first-page [data] payload. Best-effort: a cache write
  /// failure is a side effect, not part of the result, so it is swallowed.
  Future<void> _cacheFeaturedStores(Map<String, dynamic> data) async {
    try {
      await _featuredStoresDatabaseService.saveFeaturedStores(jsonEncode(data));
    } catch (_) {
      // Intentionally ignored — caching must never break a successful fetch.
    }
  }

  /// Serves the cached first page when the server is unreachable. Only the first
  /// page is cached, so any other page (or a missing/corrupt cache) surfaces the
  /// original [serverFailure].
  Future<Either<Failure, PaginationModel<StoreModel>>>
  _readFeaturedStoresFromCache(int page, Failure serverFailure) async {
    if (page != PaginatedViewModel.firstPageNumber) {
      return Left<Failure, PaginationModel<StoreModel>>(serverFailure);
    }

    try {
      final String? cached = _featuredStoresDatabaseService.getFeaturedStores();
      if (cached == null) {
        return Left<Failure, PaginationModel<StoreModel>>(serverFailure);
      }

      final Map<String, dynamic> data =
          jsonDecode(cached) as Map<String, dynamic>;
      return Right<Failure, PaginationModel<StoreModel>>(
        _parseFeaturedStores(data),
      );
    } catch (_) {
      return Left<Failure, PaginationModel<StoreModel>>(serverFailure);
    }
  }

  /// Parses the raw server `data` object into a page of stores — the same
  /// mapping for a live response and a cached one.
  PaginationModel<StoreModel> _parseFeaturedStores(Map<String, dynamic> data) {
    final Map<String, dynamic> paginationData =
        data['pagination'] as Map<String, dynamic>;
    final List<dynamic> rawItems =
        data['items'] as List<dynamic>? ?? <dynamic>[];
    final List<StoreModel> stores = rawItems
        .map((dynamic e) => StoreModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return PaginationModel<StoreModel>.fromJson(paginationData, stores);
  }

  Future<Either<Failure, StoreModel>> getStoreDetails({
    required int storeId,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _storesApiService.getStoreDetails(
        storeId: storeId,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;

      final StoreModel store = StoreModel.fromJson(
        (data['store'] ?? data) as Map<String, dynamic>?,
      );

      return Right(store);
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (exception,stackTrack) {
      print(stackTrack);
      return Left(Failure(exception.toString()));
    }
  }

  Future<Either<Failure, PaginationModel<ProductModel>>>
  getStoreCategoryProducts({
    required int storeId,
    required int? categoryId,
    required String filter,
    required int page,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _storesApiService
          .getStoreCategoryProducts(
            storeId: storeId,
            categoryId: categoryId,
            filter: filter,
            page: page,
          );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final Map<String, dynamic> paginationData =
          data['pagination'] as Map<String, dynamic>;
      final List<dynamic> rawCategoryProducts =
          data['items'] as List<dynamic>? ?? <dynamic>[];

      final List<ProductModel> products = rawCategoryProducts
          .map((dynamic e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final PaginationModel<ProductModel> paginatedProducts =
          PaginationModel<ProductModel>.fromJson(paginationData, products);

      return Right(paginatedProducts);
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (exception) {
      return Left(Failure(exception.toString()));
    }
  }
}
