import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/orders/data/datasources/remote/api/orders_endpoints.dart';

/// Raw API calls for the orders feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer).
///
/// Cancellation is fully encapsulated here: every request carries the token
/// of [_canceller], and callers only see the plain [cancelRequests] method.
class OrdersApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  Future<Response> getMyOrders({required int page}) {
    OrdersEndpoints.page = page;
    return _dio.get(
      OrdersEndpoints.getMyOrders,
      queryParameters: OrdersEndpoints.getMyOrdersQuery,
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getOrderDetails({required String orderUuid}) {
    return _dio.get(
      OrdersEndpoints.getOrderDetails(orderUuid),
      cancelToken: _canceller.token,
    );
  }
}
