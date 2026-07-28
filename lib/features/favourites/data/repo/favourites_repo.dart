import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/favourites/data/datasources/remote/api/favourites_api_service.dart';
import 'package:nowdelivery_user_app/features/favourites/data/models/favourite_model.dart';

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

  Future<Either<Failure, FavouriteModel>> addProductToFavourites({
    required int productId,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _favouritesApiService
          .addProductToFavourites(productId: productId);

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200 && response.statusCode != 201) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final Map<String, dynamic>? rawFavourite =
          data['favorite'] as Map<String, dynamic>?;

      final FavouriteModel favourite = FavouriteModel.fromJson(rawFavourite);

      return Right(favourite);
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

  Future<Either<Failure, FavouriteModel>> addStoreToFavourites({
    required int storeId,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _favouritesApiService
          .addStoreToFavourites(storeId: storeId);

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200 && response.statusCode != 201) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final Map<String, dynamic>? rawFavourite =
          data['favorite'] as Map<String, dynamic>?;

      final FavouriteModel favourite = FavouriteModel.fromJson(rawFavourite);

      return Right(favourite);
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

  Future<Either<Failure, void>> removeProductFromFavourites({
    required int productId,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _favouritesApiService
          .removeProductFromFavourites(productId: productId);

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200 && response.statusCode != 201) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      return const Right(null);
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

  Future<Either<Failure, void>> removeStoreFromFavourites({
    required int storeId,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _favouritesApiService
          .removeStoreFromFavourites(storeId: storeId);

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200 && response.statusCode != 201) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      return const Right(null);
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
