import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/checkout/data/datasources/remote/api/checkout_api_service.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';

class CheckoutRepo {
  final CheckoutApiService _checkoutApiService = CheckoutApiService();


  void cancelRequests() => _checkoutApiService.cancelRequests();


  Future<Either<Failure, CheckoutModel>> checkout({int? vendorId}) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _checkoutApiService.checkout(
        vendorId: vendorId,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if (!success) {
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


  Future<Either<Failure, CheckoutModel>> applyCoupons({
    required String orderGroupUuid,
    required Map<int, String> coupons,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _checkoutApiService.applyCoupons(
        orderGroupUuid: orderGroupUuid,
        coupons: coupons,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if (!success) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final CheckoutModel checkout = CheckoutModel.fromJson(
        body['data'] as Map<String, dynamic>?,
      );

      // The request can succeed while the coupon itself is rejected (expired,
      // not found, …). For every vendor we submitted a code for, surface the
      // server's reason of the first coupon that was not applied.
      for (final int vendorId in coupons.keys) {
        for (final CouponModel coupon in checkout.orderGroup.coupons) {
          if (coupon.vendorId == vendorId && !coupon.applied) {
            return Left(
              Failure(
                coupon.reason ?? ApiErrorHandler.extractErrorMessage(body),
              ),
            );
          }
        }
      }

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


  Future<Either<Failure, void>> confirmOrder({
    required String orderGroupUuid,
    int? addressId,
    String? paymentMethod,
    double? driverTip,
    String? notes,
    Map<int, String>? coupons,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _checkoutApiService.confirmOrder(
        orderGroupUuid: orderGroupUuid,
        addressId: addressId,
        paymentMethod: paymentMethod,
        driverTip: driverTip,
        notes: notes,
        coupons: coupons,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if (!success && response.statusCode == 422) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      return const Right(null);
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
