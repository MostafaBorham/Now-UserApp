import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/checkout/data/datasources/remote/api/checkout_api_service.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';

/// All data operations of the checkout feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a raw server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
class CheckoutRepo {
  final CheckoutApiService _checkoutApiService = CheckoutApiService();

  /// Cancels every in-flight request of this repo. The actual cancellation
  /// mechanism (CancelToken) lives entirely inside the data source layer.
  void cancelRequests() => _checkoutApiService.cancelRequests();

  /// Drafts an order group covering every store in the cart.
  ///
  /// Authentication is applied automatically by `AuthTokenInterceptor` from the
  /// cached session, so no token is read or passed here.
  Future<Either<Failure, CheckoutModel>> checkoutForAllStores() async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _checkoutApiService
          .checkoutForAllStores();

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if (response.statusCode != 200 || !success) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final CheckoutModel checkout = CheckoutModel.fromJson(
        body['data'] as Map<String, dynamic>?,
      );

      return Right(checkout);
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (e, stackTrace) {
      debugPrint('$e');
      debugPrint('$stackTrace');

      return Left(Failure(e.toString()));
    }
  }

  /// Drafts an order group for the single store identified by [vendorId].
  ///
  /// Authentication is applied automatically by `AuthTokenInterceptor` from the
  /// cached session, so no token is read or passed here.
  Future<Either<Failure, CheckoutModel>> checkoutForSingleStore(
    int vendorId,
  ) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _checkoutApiService
          .checkoutForSingleStore(vendorId);

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if (response.statusCode != 200 || !success) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final CheckoutModel checkout = CheckoutModel.fromJson(
        body['data'] as Map<String, dynamic>?,
      );

      return Right(checkout);
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (e, stackTrace) {
      debugPrint('$e');
      debugPrint('$stackTrace');

      return Left(Failure(e.toString()));
    }
  }
}
