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

  /// The customer's most recent delivered order and whether it still owes a
  /// rating: `/api/v1/ratings/orders/last-delivered` (GET).
  static const String lastDeliveredOrder =
      '/api/v1/ratings/orders/last-delivered';

  static const int perPage = 15;

  /// Every backend status of an order that is still on its way to the
  /// customer, for the home live-orders strip. These are the server's own keys,
  /// not `OrderStatus.apiKey`: the app folds `arrived_store` into `ready` and
  /// `picked_up` into `on_the_way`, so filtering by the folded keys would drop
  /// an order while the courier is at the store or just after pickup.
  static const List<String> liveStatuses = <String>[
    'pending',
    'accepted',
    'preparing',
    'ready',
    'arrived_store',
    'picked_up',
    'on_the_way',
  ];

  /// Query parameters for [getMyOrders]; [statuses] narrows the list to orders
  /// in any of those backend states.
  static Map<String, dynamic> getMyOrdersQuery(
    int page, {
    List<String>? statuses,
  }) => {
    'per_page': perPage,
    'page': page,
    'status': ?statuses,
  };
}
