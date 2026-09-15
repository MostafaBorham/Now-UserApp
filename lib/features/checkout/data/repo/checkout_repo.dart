import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/checkout/data/datasources/remote/api/checkout_api_service.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/vendor_discount_application_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';

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




  Future<Either<Failure, CheckoutModel>> checkoutForSingleStore({
    required int vendorId,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _checkoutApiService.checkoutForSingleStore(
        vendorId: vendorId,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if (!success) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final CheckoutModel checkout = CheckoutModel.fromSingleStoreJson(
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








  Future<Either<Failure, VendorDiscountApplicationModel>> applyCoupon({
    required int vendorId,
    required String code,
  }) => _applyDiscount(
    () => _checkoutApiService.applyCoupon(vendorId: vendorId, code: code),
  );




  Future<Either<Failure, VendorDiscountApplicationModel>> applyPurchaseVoucher({
    required int vendorId,
    required String code,
  }) => _applyDiscount(
    () => _checkoutApiService.applyPurchaseVoucher(
      vendorId: vendorId,
      code: code,
    ),
  );

  Future<Either<Failure, VendorDiscountApplicationModel>> _applyDiscount(
    Future<Response> Function() request,
  ) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await request();

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if (!success) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      return Right(
        VendorDiscountApplicationModel.fromJson(
          body['data'] as Map<String, dynamic>?,
        ),
      );
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




  Future<Either<Failure, List<OrderModel>>> confirmOrder({
    required String orderGroupUuid,
    required String idempotencyKey,
    int? addressId,
    String? paymentMethod,
    double? driverTip,
    String? notes,
    String? deliveryInstructions,
    Map<int, String>? coupons,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _checkoutApiService.confirmOrder(
        orderGroupUuid: orderGroupUuid,
        idempotencyKey: idempotencyKey,
        addressId: addressId,
        paymentMethod: paymentMethod,
        driverTip: driverTip,
        notes: notes,
        deliveryInstructions: deliveryInstructions,
        coupons: coupons,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      final bool success = body['success'] as bool? ?? false;

      if (!success) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }



      final Map<String, dynamic>? data =
          body['data'] as Map<String, dynamic>?;
      final Map<String, dynamic> group =
          (data?['order_group'] as Map<String, dynamic>?) ??
          data ??
          const <String, dynamic>{};
      final List<OrderModel> orders =
          ((group['orders'] as List?) ?? const <dynamic>[])
              .map((e) => OrderModel.fromJson(e as Map<String, dynamic>?))
              .toList();

      return Right(orders);
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
