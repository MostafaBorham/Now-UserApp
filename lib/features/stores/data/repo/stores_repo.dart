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

class StoresRepo {
  final StoresApiService _storesApiService = StoresApiService();
  final FeaturedStoresDatabaseService _featuredStoresDatabaseService =
      FeaturedStoresDatabaseService();

  void cancelRequests() => _storesApiService.cancelRequests();

  Future<Either<Failure, PaginationModel<StoreModel>>> getStores({
    required int page,
    String? search,
    int? categoryId,
    String? rating,
  }) {
    return _guard(
      () => _storesApiService.getStores(
        page: page,
        search: search,
        categoryId: categoryId,
        rating: rating,
      ),
      (Map<String, dynamic> data) {
        final Map<String, dynamic> meta =
            (data['meta'] ?? data['pagination']) as Map<String, dynamic>? ??
            <String, dynamic>{};
        final List<dynamic> rawItems =
            (data['items'] ?? data['stores']) as List<dynamic>? ?? <dynamic>[];
        return PaginationModel<StoreModel>.fromJson(meta, _stores(rawItems));
      },
    );
  }

  /// The featured stores, falling back to the cached first page whenever the
  /// server cannot answer — so the "Best brands" carousel still has something to
  /// show offline. Only page one is cached; a failed later page is just a
  /// failure.
  Future<Either<Failure, PaginationModel<StoreModel>>> getFeaturedStores({
    required int page,
  }) async {
    final Either<Failure, Map<String, dynamic>> serverResult = await _guard(
      () => _storesApiService.getFeaturedStores(page: page),
      (Map<String, dynamic> data) => data,
    );

    return serverResult.fold(
      (Failure serverFailure) =>
          _readFeaturedStoresFromCache(page, serverFailure),
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

  Future<void> _cacheFeaturedStores(Map<String, dynamic> data) async {
    try {
      await _featuredStoresDatabaseService.saveFeaturedStores(jsonEncode(data));
    } catch (_) {}
  }

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

  PaginationModel<StoreModel> _parseFeaturedStores(Map<String, dynamic> data) {
    final Map<String, dynamic> paginationData =
        data['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> rawItems =
        data['items'] as List<dynamic>? ?? <dynamic>[];
    return PaginationModel<StoreModel>.fromJson(
      paginationData,
      _stores(rawItems),
    );
  }

  Future<Either<Failure, StoreModel>> getStoreDetails({required int storeId}) {
    return _guard(
      () => _storesApiService.getStoreDetails(storeId: storeId),
      (Map<String, dynamic> data) =>
          StoreModel.fromJson((data['store'] ?? data) as Map<String, dynamic>?),
    );
  }

  /// One page of a store's products. [categoryId] narrows them to one of the
  /// store's own categories (the store-details category chips); [filter] is the
  /// filter tab (`all`, `offer`, `top_rated`, …).
  Future<Either<Failure, PaginationModel<ProductModel>>> getStoreProducts({
    required int storeId,
    required int? categoryId,
    required String filter,
    required int page,
    String? search,
  }) {
    return _guard(
      () => _storesApiService.getStoreProducts(
        storeId: storeId,
        categoryId: categoryId,
        filter: filter,
        page: page,
        search: search,
      ),
      (Map<String, dynamic> data) {
        final Map<String, dynamic> paginationData =
            data['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};
        final List<dynamic> rawItems =
            data['items'] as List<dynamic>? ?? <dynamic>[];
        final List<ProductModel> products = rawItems
            .whereType<Map<String, dynamic>>()
            .map(ProductModel.fromJson)
            .toList();
        return PaginationModel<ProductModel>.fromJson(paginationData, products);
      },
    );
  }

  List<StoreModel> _stores(List<dynamic> rawItems) => rawItems
      .whereType<Map<String, dynamic>>()
      .map(StoreModel.fromJson)
      .toList();

  /// Runs [request] and hands the success envelope's `data` object to [parse].
  ///
  /// The body is only read as a map *after* the status says it is that success
  /// envelope: an error response can carry a list or a plain string, and casting
  /// first turned that into a `CastError` that the catch-all then showed to the
  /// customer as a raw Dart exception string. Every failure out of here is
  /// either a server-supplied message or a [LangKeys] key.
  Future<Either<Failure, T>> _guard<T>(
    Future<Response> Function() request,
    T Function(Map<String, dynamic> data) parse,
  ) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await request();
      final Map<String, dynamic>? body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : null;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }
      if (body == null) {
        return const Left(Failure(LangKeys.serverConnectionFailedKey));
      }

      return Right(
        parse(body['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      );
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (_) {
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }
}
