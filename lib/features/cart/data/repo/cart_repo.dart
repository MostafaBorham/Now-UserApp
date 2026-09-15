import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/cart/data/datasources/remote/api/cart_api_service.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';

class CartRepo {
  final CartApiService _cartApiService = CartApiService();

  void cancelRequests() => _cartApiService.cancelRequests();

  Future<Either<Failure, CartModel>> getCart() async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _cartApiService.getCart();

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if (response.statusCode != 200 || !success) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final CartModel cart = CartModel.fromJson(
        body['data'] as Map<String, dynamic>?,
      );

      return Right(cart);
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, CartModel>> deleteCartProduct(int productId) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _cartApiService.deleteCartProduct(
        productId,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if (response.statusCode != 200 || !success) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final CartModel cart = CartModel.fromJson(
        body['data'] as Map<String, dynamic>?,
      );

      return Right(cart);
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, CartModel>> deleteCartVendorItem(int vendorId) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _cartApiService.deleteCartVendorItem(
        vendorId,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if (response.statusCode != 200 || !success) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final CartModel cart = CartModel.fromJson(
        body['data'] as Map<String, dynamic>?,
      );

      return Right(cart);
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, CartModel>> updateCartProductQuantity(
    int productId,
    int quantity,
  ) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _cartApiService.updateCartProductQuantity(
        productId,
        quantity,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if (response.statusCode != 200 || !success) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final CartModel cart = CartModel.fromJson(
        body['data'] as Map<String, dynamic>?,
      );

      return Right(cart);
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, CartModel>> addToCart(
    int productId,
    int quantity,
  ) async {


    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _cartApiService.addToCart(
        productId,
        quantity,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if ((response.statusCode != 200 && response.statusCode != 201) ||
          !success) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final CartModel cart = CartModel.fromJson(
        body['data'] as Map<String, dynamic>?,
      );

      return Right(cart);
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
