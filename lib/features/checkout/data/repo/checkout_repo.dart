import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/dio/api_response.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/checkout/data/datasources/remote/api/checkout_api_service.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/vendor_discount_application_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';

class CheckoutRepo {
  final CheckoutApiService _checkoutApiService = CheckoutApiService();

  void cancelRequests() => _checkoutApiService.cancelRequests();

  /// Prices the checkout of [vendorId] (`null` = the whole cart) with the
  /// choices in [body]. The two flavours answer in different shapes — the cart
  /// one groups by vendor, the vendor one is a single store — so each has its
  /// own parser onto the shared [CheckoutModel].
  Future<Either<Failure, CheckoutModel>> preview({
    int? vendorId,
    Map<String, dynamic> body = const <String, dynamic>{},
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _checkoutApiService.preview(
        vendorId: vendorId,
        body: body,
      );

      return readApiResponse(response, requireSuccessFlag: true).map((
        Map<String, dynamic> body,
      ) {
        final Map<String, dynamic>? data =
            body['data'] as Map<String, dynamic>?;
        return vendorId == null
            ? CheckoutModel.fromJson(data)
            : CheckoutModel.fromSingleStoreJson(data);
      });
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

  /// Applies coupon [code] for [vendorId] via the stateless
  /// `POST /api/v1/coupons/apply` calculator.
  ///
  /// A rejected code is **not** a [Left]: the request returns 200 with
  /// `applied:false` and a reason, so the model is returned either way and the
  /// caller inspects [VendorDiscountApplicationModel.applied]. [Left] is only
  /// for transport/domain failures (offline, 422, network).
  Future<Either<Failure, VendorDiscountApplicationModel>> applyCoupon({
    required int vendorId,
    required String code,
  }) => _applyDiscount(
    () => _checkoutApiService.applyCoupon(vendorId: vendorId, code: code),
  );

  /// Applies purchase-voucher [code] for [vendorId] via the stateless
  /// `POST /api/v1/purchase-vouchers/apply` calculator. Same semantics as
  /// [applyCoupon].
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

      return readApiResponse(response, requireSuccessFlag: true).map(
        (Map<String, dynamic> body) => VendorDiscountApplicationModel.fromJson(
          body['data'] as Map<String, dynamic>?,
        ),
      );
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

  /// Places the order for [vendorId] (`null` = the whole cart) and returns the
  /// orders the server created (each carrying its real `order_number`, status,
  /// etc.), so the confirmation screen renders placed orders, not the preview.
  Future<Either<Failure, List<OrderModel>>> placeOrder({
    int? vendorId,
    required String idempotencyKey,
    required Map<String, dynamic> body,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _checkoutApiService.placeOrder(
        vendorId: vendorId,
        idempotencyKey: idempotencyKey,
        body: body,
      );

      return readApiResponse(response, requireSuccessFlag: true).map((
        Map<String, dynamic> body,
      ) {
        final Map<String, dynamic> group =
            ((body['data'] as Map<String, dynamic>?)?['order_group']
                as Map<String, dynamic>?) ??
            const <String, dynamic>{};

        return ((group['orders'] as List?) ?? const <dynamic>[])
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>?))
            .toList();
      });
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
