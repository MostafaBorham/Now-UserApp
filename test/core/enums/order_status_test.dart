import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/enums/order_status.dart';

// Every key the backend sends (`OrderStatus.php`) must land on a modelled
// state: an unmodelled one fell to UnknownStatus, and tracking lost its
// timeline, courier and Track button between pickup and the road.
void main() {
  test('the courier stages stay trackable', () {
    expect(OrderStatus.fromKey('arrived_store'), isA<ReadyStatus>());
    expect(OrderStatus.fromKey('picked_up'), isA<OnTheWayStatus>());
    expect(OrderStatus.fromKey('arrived_store').isTrackable, isTrue);
    expect(OrderStatus.fromKey('picked_up').isTrackable, isTrue);
  });

  test('closed is a delivered order, rejected a cancelled one', () {
    expect(OrderStatus.fromKey('closed'), isA<DeliveredStatus>());
    expect(OrderStatus.fromKey('closed').isRateable, isTrue);
    expect(OrderStatus.fromKey('closed').hasInvoice, isTrue);
    expect(OrderStatus.fromKey('rejected'), isA<CancelledStatus>());
  });

  test('an order closed before it was delivered is not a delivered one', () {
    final OrderStatus status = OrderStatus.fromKey(
      'closed',
      wasDelivered: false,
    );

    expect(status, isA<CancelledStatus>());
    expect(status.isRateable, isFalse);
  });
}
