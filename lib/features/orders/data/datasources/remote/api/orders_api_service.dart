import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/orders/data/datasources/remote/api/orders_endpoints.dart';









class OrdersApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();


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

  Future<Response> cancelOrder({required String orderUuid}) {
    return _dio.put(
      OrdersEndpoints.cancelOrder(orderUuid),
      cancelToken: _canceller.token,
    );
  }
}
