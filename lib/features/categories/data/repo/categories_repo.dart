import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/categories/data/datasources/remote/api/categories_api_service.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';

/// All data operations of the categories feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a raw server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
class CategoriesRepo {
  final CategoriesApiService _categoriesApiService = CategoriesApiService();

  /// Cancels every in-flight request of this repo. The actual cancellation
  /// mechanism (CancelToken) lives entirely inside the data source layer.
  void cancelRequests() => _categoriesApiService.cancelRequests();

  Future<Either<Failure, PaginationModel<CategoryModel>>> getAppCategories({
    required int page,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _categoriesApiService.getAppCategories(
        page: page,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final Map<String, dynamic> paginationData =
          data['meta'] as Map<String, dynamic>;
      final List<dynamic> rawCategories =
          data['categories'] as List<dynamic>? ?? <dynamic>[];

      final List<CategoryModel> categories = rawCategories
          .map((dynamic e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final PaginationModel<CategoryModel> paginatedCategories =
          PaginationModel<CategoryModel>.fromJson(paginationData, categories);

      return Right(paginatedCategories);
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

  Future<Either<Failure, List<CategoryModel>>> getProductSubCategories() async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _categoriesApiService
          .getProductSubCategories();

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final List<dynamic> rawCategories =
          data['categories'] as List<dynamic>? ?? <dynamic>[];

      final List<CategoryModel> categories = rawCategories
          .map((dynamic e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(categories);
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

  Future<Either<Failure, List<CategoryModel>>> getStoreSubCategories() async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _categoriesApiService
          .getStoreSubCategories();

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final List<dynamic> rawCategories =
          data['categories'] as List<dynamic>? ?? <dynamic>[];

      final List<CategoryModel> categories = rawCategories
          .map((dynamic e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(categories);
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

  Future<Either<Failure, PaginationModel<StoreModel>>> getCategoryStores({
    required String categorySlug,
    required int? categoryId,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      print('current id== $categoryId');
      final Response response = await _categoriesApiService.getCategoryStores(
        categorySlug: categorySlug,
        categoryId: categoryId,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final Map<String, dynamic> paginationData =
          data['meta'] as Map<String, dynamic>;
      final List<dynamic> rawCategoryStores =
          data['items'] as List<dynamic>? ?? <dynamic>[];

      final List<StoreModel> stores = rawCategoryStores
          .map((dynamic e) => StoreModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final PaginationModel<StoreModel> paginatedStores =
          PaginationModel<StoreModel>.fromJson(paginationData, stores);

      return Right(paginatedStores);
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

  Future<Either<Failure, PaginationModel<ProductModel>>> getCategoryProducts({
    required String categorySlug,
    required int? categoryId,
    required int page,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _categoriesApiService.getCategoryProducts(
        categorySlug: categorySlug,
        categoryId: categoryId,
        page: page,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final Map<String, dynamic> paginationData =
          data['meta'] as Map<String, dynamic>;
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
    } catch (exception, stackTrac) {
      print(stackTrac);
      return Left(Failure(exception.toString()));
    }
  }
}
