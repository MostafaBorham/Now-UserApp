import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/enums/order_status.dart';
import 'package:nowdelivery_user_app/core/enums/order_step_status.dart';
import 'package:nowdelivery_user_app/features/orders/data/datasources/remote/api/orders_endpoints.dart';

void main() {
  test('the live-orders query asks for every in-flight backend status', () {
    final Map<String, dynamic> query = OrdersEndpoints.getMyOrdersQuery(
      1,
      statuses: OrdersEndpoints.liveStatuses,
    );

    // `arrived_store` and `picked_up` are the two the app folds into `ready`
    // and `on_the_way`; filtering by the folded keys dropped those orders.
    expect(
      query['status'],
      unorderedEquals(<String>[
        'pending',
        'accepted',
        'preparing',
        'ready',
        'arrived_store',
        'picked_up',
        'on_the_way',
      ]),
    );
    for (final String key in OrdersEndpoints.liveStatuses) {
      expect(OrderStatus.fromKey(key).isTrackable, isTrue, reason: key);
    }
  });

  test('My Orders sends no status filter', () {
    expect(OrdersEndpoints.getMyOrdersQuery(2).containsKey('status'), isFalse);
  });

  test(
    'a courier waiting at the store puts "on the way" as the current step',
    () {
      final OrderStatus status = OrderStatus.fromKey('arrived_store');

      expect(
        <OrderStepStatus>[for (int i = 0; i < 4; i++) status.stepStatusAt(i)],
        <OrderStepStatus>[
          OrderStepStatus.done,
          OrderStepStatus.done,
          OrderStepStatus.current,
          OrderStepStatus.pending,
        ],
      );
    },
  );
}
