import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/orders/data/datasources/remote/api/orders_api_service.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';

/// All data operations of the orders feature.
///
/// Orders are **server-only**: there is deliberately no local cache here, so
/// every read reflects the current server state (an order's status, payment or
/// contents can change at any time). Each method returns `Either<Failure, T>`:
/// `Left` carries a user-facing error message (a [LangKeys] key or a raw server
/// message — callers apply `.tr()` which leaves non-key strings untouched),
/// `Right` carries the data.
class OrdersRepo {
  final OrdersApiService _ordersApiService = OrdersApiService();

  /// Cancels every in-flight request of this repo. The actual cancellation
  /// mechanism (CancelToken) lives entirely inside the data source layer.
  void cancelRequests() => _ordersApiService.cancelRequests();

  /// One page of the signed-in user's orders, always fetched from the server.
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
