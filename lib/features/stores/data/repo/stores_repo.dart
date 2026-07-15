import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/stores/data/datasources/remote/api/stores_api_service.dart';

/// All data operations of the stores feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a raw server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
class StoresRepo {
  final StoresApiService _storesApiService = StoresApiService();

  /// Cancels every in-flight request of this repo. The actual cancellation
  /// mechanism (CancelToken) lives entirely inside the data source layer.
  void cancelRequests() => _storesApiService.cancelRequests();

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
    } catch (exception) {
      return Left(Failure(exception.toString()));
    }
  }

  Future<Either<Failure, List<ProductModel>>> getStoreCategoryProducts({
    required String categorySlug,
    required int? categoryId,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _storesApiService
          .getStoreCategoryProducts(
            categorySlug: categorySlug,
            categoryId: categoryId,
          );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final List<dynamic> rawCategoryProducts =
          data['items'] as List<dynamic>? ?? <dynamic>[];

      final List<ProductModel> products = rawCategoryProducts
          .map((dynamic e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(products);
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
