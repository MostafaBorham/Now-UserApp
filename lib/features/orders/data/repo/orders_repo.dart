import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/orders/data/datasources/local/database/orders_database_service.dart';
import 'package:nowdelivery_user_app/features/orders/data/datasources/remote/api/orders_api_service.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';

/// All data operations of the orders feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a raw server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
class OrdersRepo {
  final OrdersApiService _ordersApiService = OrdersApiService();
  final OrdersDatabaseService _ordersDatabaseService = OrdersDatabaseService();

  /// Cancels every in-flight request of this repo. The actual cancellation
  /// mechanism (CancelToken) lives entirely inside the data source layer.
  void cancelRequests() => _ordersApiService.cancelRequests();

  /// Drops the cached orders (e.g. on logout, so the next user never sees the
  /// previous user's orders from Hive). Best-effort: a clear failure is ignored.
  Future<void> clearCachedOrders() async {
    try {
      await _ordersDatabaseService.clearAll();
    } catch (_) {
      // Best-effort; ignore.
    }
  }

  /// The first page of orders cached in Hive, or `null` when nothing usable is
  /// cached yet — so callers can decide whether to hit the API.
  ///
  /// A corrupt or unreadable cache is treated as "nothing cached" (returns
  /// `null`) rather than an error: the caller then falls back to the API, which
  /// is exactly what an empty cache should do.
  PaginationModel<OrderModel>? getCachedOrders() {
    try {
      final dynamic raw = _ordersDatabaseService.getCachedOrders();
      if (raw is! String || raw.isEmpty) return null;

      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      final List<dynamic> rawOrders =
          decoded['orders'] as List<dynamic>? ?? <dynamic>[];
      if (rawOrders.isEmpty) return null;

      final Map<String, dynamic> paginationData =
          decoded['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final List<OrderModel> orders = rawOrders
          .map((dynamic e) => OrderModel.fromJson(e as Map<String, dynamic>?))
          .toList();

      return PaginationModel<OrderModel>.fromJson(paginationData, orders);
    } catch (_) {
      return null;
    }
  }

  /// One page of the signed-in user's orders.
  ///
  /// This endpoint names its envelope keys `orders` / `pagination` (not the
  /// `items` / `meta` the category endpoints use), hence the different reads.
  Future<Either<Failure, PaginationModel<OrderModel>>> getMyOrders({
    required int page,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _ordersApiService.getMyOrders(page: page);

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final Map<String, dynamic> paginationData =
          data['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final List<dynamic> rawOrders =
          data['orders'] as List<dynamic>? ?? <dynamic>[];

      final List<OrderModel> orders = rawOrders
          .map((dynamic e) => OrderModel.fromJson(e as Map<String, dynamic>?))
          .toList();
      final PaginationModel<OrderModel> paginatedOrders =
          PaginationModel<OrderModel>.fromJson(paginationData, orders);

      // Refresh the cache from the first page (initial load, pull-to-refresh or
      // retry) so a later open can render from Hive without a request. A cache
      // write failure must never turn a successful fetch into an error, so it is
      // swallowed.
      if (paginatedOrders.currentPage == 1) {
        try {
          await _ordersDatabaseService.saveOrders(
            jsonEncode(<String, dynamic>{
              'orders': rawOrders,
              'pagination': paginationData,
            }),
          );
        } catch (_) {
          // Best-effort cache; ignore write failures.
        }
      }

      return Right(paginatedOrders);
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
