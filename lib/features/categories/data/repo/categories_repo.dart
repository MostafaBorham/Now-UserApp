import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/dio/api_response.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/utils/isolate/isolate_runner.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/datasources/local/database/app_categories_database_service.dart';
import 'package:nowdelivery_user_app/features/categories/data/datasources/remote/api/categories_api_service.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';







class CategoriesRepo {
  final CategoriesApiService _categoriesApiService = CategoriesApiService();
  final AppCategoriesDatabaseService _appCategoriesDatabaseService =
      AppCategoriesDatabaseService();



  static const String _categoriesListKey = 'categories';



  void cancelRequests() => _categoriesApiService.cancelRequests();











  Future<Either<Failure, PaginationModel<CategoryModel>>> getAppCategories({
    required int page,
    String? search,
  }) async {
    final bool isSearching = search != null && search.isNotEmpty;



    final Either<Failure, Map<String, dynamic>> serverResult = await _guard(
      () => _categoriesApiService.getAppCategories(page: page, search: search),
      (Map<String, dynamic> data) => data,
    );

    return serverResult.fold(

      (Failure serverFailure) => isSearching
          ? Left<Failure, PaginationModel<CategoryModel>>(serverFailure)
          : _readCategoriesFromCache(page, serverFailure),

      (Map<String, dynamic> data) async {
        if (!isSearching && page == PaginatedViewModel.firstPageNumber) {
          await _cacheAppCategories(data);
        }
        return Right<Failure, PaginationModel<CategoryModel>>(
          _paginated(data, _categoriesListKey, CategoryModel.fromJson),
        );
      },
    );
  }



  Future<void> _cacheAppCategories(Map<String, dynamic> data) async {
    try {
      await _appCategoriesDatabaseService.saveAppCategories(jsonEncode(data));
    } catch (_) {

    }
  }




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

      final PaginationModel<CategoryModel> categories =
          await IsolateRunner.parseJson<PaginationModel<CategoryModel>>(
            cached,
            _decodeCachedCategories,
          );
      return Right<Failure, PaginationModel<CategoryModel>>(categories);
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

PaginationModel<CategoryModel> _decodeCachedCategories(Object? decoded) {
  final Map<String, dynamic> data = decoded as Map<String, dynamic>;
  final Map<String, dynamic> meta = data['meta'] as Map<String, dynamic>;
  final List<dynamic> rawItems =
      data['categories'] as List<dynamic>? ?? <dynamic>[];
  final List<CategoryModel> items = rawItems
      .map((dynamic e) => CategoryModel.fromJson(e as Map<String, dynamic>))
      .toList();
  return PaginationModel<CategoryModel>.fromJson(meta, items);
}
