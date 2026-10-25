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

  test('a partially returned order is still a delivered one', () {
    final OrderStatus status = OrderStatus.fromKey('partially_returned');

    expect(status, isA<PartiallyReturnedStatus>());
    expect(status, isA<DeliveredStatus>());
    expect(status.apiKey, 'partially_returned');
    expect(status.isRateable, isTrue);
    expect(status.hasInvoice, isTrue);
    expect(status.isTrackable, isFalse);
    expect(status.isCancellable, isFalse);
    for (int step = 0; step < 4; step++) {
      expect(
        status.stepStatusAt(step),
        OrderStatus.fromKey('delivered').stepStatusAt(step),
      );
    }
  });

  test('a returned order is finished, not active and not delivered', () {
    final OrderStatus status = OrderStatus.fromKey('returned');

    expect(status, isA<ReturnedStatus>());
    expect(status, isNot(isA<DeliveredStatus>()));
    expect(status.isTrackable, isFalse);
    expect(status.isCancellable, isFalse);
    expect(status.isRateable, isFalse);
  });

  test('an unknown key does not throw', () {
    expect(OrderStatus.fromKey('something_new'), isA<UnknownStatus>());
    expect(OrderStatus.fromKey(null), isA<UnknownStatus>());
  });
}
