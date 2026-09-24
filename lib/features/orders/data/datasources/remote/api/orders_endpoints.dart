/// API endpoints owned by the orders feature.
abstract class OrdersEndpoints {
  static const String getMyOrders = '/api/v1/my/orders';

  /// Single order details: `/api/v1/my/orders/{order_uuid}`.
  static String getOrderDetails(String orderUuid) =>
      '$getMyOrders/$orderUuid';

  /// Cancel an order: `/api/v1/my/orders/{order_uuid}/cancel` (PUT).
  static String cancelOrder(String orderUuid) =>
      '$getMyOrders/$orderUuid/cancel';

  /// Rate an order: `/api/v1/ratings/orders/{order_id}` (POST). Submits the
  /// per-product, vendor and delivery scores in one request.
  static String rateOrder(int orderId) => '/api/v1/ratings/orders/$orderId';

  static const int perPage = 15;

  /// Query parameters for [getMyOrders].
  static Map<String, dynamic> getMyOrdersQuery(int page) => {
    'per_page': perPage,
    'page': page,
  };
}
