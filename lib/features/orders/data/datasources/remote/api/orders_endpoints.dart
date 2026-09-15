
abstract class OrdersEndpoints {
  static const String getMyOrders = '/api/v1/my/orders';


  static String getOrderDetails(String orderUuid) =>
      '$getMyOrders/$orderUuid';


  static String cancelOrder(String orderUuid) =>
      '$getMyOrders/$orderUuid/cancel';

  static int perPage = 15;
  static int page = 1;


  static Map<String, dynamic> get getMyOrdersQuery => {
    'per_page': perPage,
    'page': page,
  };
}
