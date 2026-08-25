import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/datasources/local/database/app_categories_database_service.dart';
import 'package:nowdelivery_user_app/features/categories/data/datasources/remote/api/categories_api_service.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';

/// All data operations of the categories feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a clean server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
/// The connection check and error mapping live in [_guard].
class CategoriesRepo {
  final CategoriesApiService _categoriesApiService = CategoriesApiService();
  final AppCategoriesDatabaseService _appCategoriesDatabaseService =
      AppCategoriesDatabaseService();

  /// The key inside the categories `data` payload that carries the list — the
  /// same key the server uses and the cached copy mirrors.
  static const String _categoriesListKey = 'categories';

  /// Cancels every in-flight request of this repo. The actual cancellation
  /// mechanism (CancelToken) lives entirely inside the data source layer.
  void cancelRequests() => _categoriesApiService.cancelRequests();

  /// The app categories list, server-first with a local (Hive) fallback.
  ///
  /// The server is always tried first, and a successful **first-page** fetch
  /// refreshes the cache so the local copy tracks the server. When the server
  /// is unreachable the first page is served from the cache instead; later
  /// pages have no cached copy and simply surface the server failure.
  Future<Either<Failure, PaginationModel<CategoryModel>>> getAppCategories({
    required int page,
  }) async {
    // Fetch the raw server `data` object so it can be both cached verbatim and
    // parsed — the cache round-trips through the same parsing the server uses.
    final Either<Failure, Map<String, dynamic>> serverResult = await _guard(
      () => _categoriesApiService.getAppCategories(page: page),
      (Map<String, dynamic> data) => data,
    );

    return serverResult.fold(
      // Server failed → fall back to the cached first page.
      (Failure serverFailure) => _readCategoriesFromCache(page, serverFailure),
      // Server succeeded → refresh the cache (first page only), then return.
      (Map<String, dynamic> data) async {
        if (page == PaginatedViewModel.firstPageNumber) {
          await _cacheAppCategories(data);
        }
        return Right<Failure, PaginationModel<CategoryModel>>(
          _paginated(data, _categoriesListKey, CategoryModel.fromJson),
        );
      },
    );
  }

  /// Persists the raw first-page [data] payload. Best-effort: a cache write
  /// failure is a side effect, not part of the result, so it is swallowed.
  Future<void> _cacheAppCategories(Map<String, dynamic> data) async {
    try {
      await _appCategoriesDatabaseService.saveAppCategories(jsonEncode(data));
    } catch (_) {
      // Intentionally ignored — caching must never break a successful fetch.
    }
  }

  /// Serves the cached first page when the server is unreachable. Only the
  /// first page is cached, so any other page (or a missing/corrupt cache)
  /// surfaces the original [serverFailure].
  Future<Either<Failure, PaginationModel<CategoryModel>>>
      _readCategoriesFromCache(int page, Failure serverFailure) async {
    if (page != PaginatedViewModel.firstPageNumber) {
      return Left<Failure, PaginationModel<CategoryModel>>(serverFailure);
    }

    try {
      final String? cached = _appCategoriesDatabaseService.getAppCategories();
      if (cached == null) {
        return Left<Failure, PaginationModel<CategoryModel>>(serverFailure);
      }

      final Map<String, dynamic> data =
          jsonDecode(cached) as Map<String, dynamic>;
      return Right<Failure, PaginationModel<CategoryModel>>(
        _paginated(data, _categoriesListKey, CategoryModel.fromJson),
      );
    } catch (_) {
      return Left<Failure, PaginationModel<CategoryModel>>(serverFailure);
    }
  }

  Future<Either<Failure, PaginationModel<StoreModel>>> getCategoryStores({
    required String categorySlug,
    required int? categoryId,
    required int page,
    String? search,
  }) {
    return _guard(
      () => _categoriesApiService.getCategoryStores(
        categorySlug: categorySlug,
        categoryId: categoryId,
        page: page,
        search: search,
      ),
      (data) => _paginated(data, 'items', StoreModel.fromJson),
    );
  }

  Future<Either<Failure, PaginationModel<ProductModel>>> getCategoryProducts({
    required String categorySlug,
    required int? categoryId,
    required int page,
    String? search,
  }) {
    return _guard(
      () => _categoriesApiService.getCategoryProducts(
        categorySlug: categorySlug,
        categoryId: categoryId,
        page: page,
        search: search,
      ),
      (data) => _paginated(data, 'items', ProductModel.fromJson),
    );
  }

  /// Turns a `{meta, <listKey>: [...]}` payload into a [PaginationModel]. The
  /// three list endpoints differ only by their list key and item type.
  PaginationModel<T> _paginated<T>(
    Map<String, dynamic> data,
    String listKey,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final Map<String, dynamic> meta = data['meta'] as Map<String, dynamic>;
    final List<dynamic> rawItems = data[listKey] as List<dynamic>? ?? <dynamic>[];
    final List<T> items = rawItems
        .map((dynamic e) => fromJson(e as Map<String, dynamic>))
        .toList();
    return PaginationModel<T>.fromJson(meta, items);
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
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      return Right(parse(body['data'] as Map<String, dynamic>));
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
