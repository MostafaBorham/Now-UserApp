import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/dio/api_response.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/orders/data/datasources/remote/api/orders_api_service.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/rate_order_request_model.dart';
import 'package:path_provider/path_provider.dart';

class OrdersRepo {
  final OrdersApiService _ordersApiService = OrdersApiService();


  void cancelRequests() => _ordersApiService.cancelRequests();


  Future<Either<Failure, PaginationModel<OrderModel>>> getMyOrders({
    required int page,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _ordersApiService.getMyOrders(page: page);

      return readApiResponse(response).map((Map<String, dynamic> body) {
        final Map<String, dynamic> data =
            body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

        final Map<String, dynamic> paginationData =
            data['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};

        final List<OrderModel> orders =
            (data['orders'] as List<dynamic>? ?? <dynamic>[])
                .map(
                  (dynamic e) => OrderModel.fromJson(e as Map<String, dynamic>?),
                )
                .toList();

        return PaginationModel<OrderModel>.fromJson(paginationData, orders);
      });
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

  Future<Either<Failure, OrderModel>> getOrderDetails({
    required String orderUuid,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _ordersApiService.getOrderDetails(
        orderUuid: orderUuid,
      );

      return readApiResponse(response).map((Map<String, dynamic> body) {
        final Map<String, dynamic> data =
            body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

        return OrderModel.fromJson(data['order'] as Map<String, dynamic>?);
      });
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




  Future<Either<Failure, Unit>> cancelOrder({
    required String orderUuid,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _ordersApiService.cancelOrder(
        orderUuid: orderUuid,
      );

      return readApiResponse(response).map((_) => unit);
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

  /// Downloads the invoice PDF at [url] into the temp directory and returns the
  /// file's path, for the in-app viewer. Every failure is the viewer's one
  /// message: the server's are English-only, about states the button is never
  /// offered in.
  Future<Either<Failure, String>> downloadInvoice({required String url}) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response<List<int>> response = await _ordersApiService
          .downloadInvoice(url: url);
      final List<int>? bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        return const Left(Failure(LangKeys.invoiceDownloadFailedKey));
      }

      final Directory directory = await getTemporaryDirectory();
      // One file, overwritten by the next invoice opened, so they don't pile up.
      final File file = await File(
        '${directory.path}/invoice.pdf',
      ).writeAsBytes(bytes, flush: true);
      return Right(file.path);
    } catch (_) {
      return const Left(Failure(LangKeys.invoiceDownloadFailedKey));
    }
  }

  Future<Either<Failure, Unit>> rateOrder({
    required RateOrderRequest request,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _ordersApiService.rateOrder(
        orderId: request.orderId,
        body: request.toJson(),
      );

      return readApiResponse(response, requireSuccessFlag: true).map((_) => unit);
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
