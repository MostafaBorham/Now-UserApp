/// API endpoints owned by the orders feature.
abstract class OrdersEndpoints {
  static const String getMyOrders = '/api/v1/my/orders';

  static int perPage = 15;
  static int page = 1;

  /// Query parameters for getMyOrders
  static Map<String, dynamic> get getMyOrdersQuery => {
    'per_page': perPage,
    'page': page,
  };
}
