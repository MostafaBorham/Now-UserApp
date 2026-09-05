/// API endpoints owned by the orders feature.
abstract class OrdersEndpoints {
  static const String getMyOrders = '/api/v1/my/orders';

  /// Single order details: `/api/v1/my/orders/{order_uuid}`.
  static String getOrderDetails(String orderUuid) =>
      '$getMyOrders/$orderUuid';

  static int perPage = 15;
  static int page = 1;

  /// Query parameters for getMyOrders
  static Map<String, dynamic> get getMyOrdersQuery => {
    'per_page': perPage,
    'page': page,
  };
}
