import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/dio/api_response.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/orders/data/datasources/local/rate_prompt_cache_service.dart';
import 'package:nowdelivery_user_app/features/orders/data/datasources/remote/api/orders_api_service.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/rate_order_request_model.dart';
import 'package:path_provider/path_provider.dart';

class OrdersRepo {
  final OrdersApiService _ordersApiService = OrdersApiService();
  final RatePromptCacheService _ratePromptCache = RatePromptCacheService();

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
    } catch (_) {
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
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
    } catch (_) {
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
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
    } catch (_) {
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
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

  /// The last delivered order when it still owes a rating and the prompt has
  /// not been shown for it yet — otherwise null, and nothing to prompt about.
  Future<Either<Failure, OrderModel?>> getOrderToPromptForRating() async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _ordersApiService.getLastDeliveredOrder();

      return readApiResponse(response).map((Map<String, dynamic> body) {
        final OrderModel? order = pendingRatingOrder(
          body['data'] as Map<String, dynamic>?,
        );
        final int? id = order?.id;
        if (id == null || _ratePromptCache.wasPrompted(id)) return null;
        return order;
      });
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

  /// Remembers that the prompt was shown for [orderId], so it is not offered
  /// for that order again.
  Future<void> markRatePromptShown(int orderId) =>
      _ratePromptCache.markPrompted(orderId);

  /// The order in a `last-delivered` payload ([data] is its `data`), or null
  /// when there is nothing to rate: no delivered order at all,
  /// `has_pending_rating` false (everything rated, or not rateable), or
  /// anything on it rated already — rating is one-shot in the app, even when
  /// the backend would take the rest.
  ///
  /// The order block carries the rating sheet — `can_rate`, `is_rated`,
  /// `products`, `vendor`, `delivery` — at its top level rather than under
  /// `rating`, so it is also read as its own `rating`. The rating screen and the
  /// prompt then work from [OrderModel.rating] exactly as they do for an order
  /// from `/my/orders`.
  static OrderModel? pendingRatingOrder(Map<String, dynamic>? data) {
    final Map<String, dynamic>? order =
        data?['last_delivered_order'] as Map<String, dynamic>?;
    if (order == null ||
        data?['has_pending_rating'] != true ||
        order['is_rated'] == true) {
      return null;
    }
    return OrderModel.fromJson(<String, dynamic>{...order, 'rating': order});
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
    } catch (_) {
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }
}
