







sealed class OrderStatus {
  const OrderStatus(this.apiKey);


  final String apiKey;





  bool get isTrackable => false;





  bool get isCancellable => false;



  static OrderStatus fromKey(String? key) => switch (key) {
    'pending' => const PendingStatus(),
    'accepted' => const AcceptedStatus(),
    'preparing' => const PreparingStatus(),
    'ready' => const ReadyStatus(),
    'on_the_way' => const OnTheWayStatus(),
    'delivered' => const DeliveredStatus(),
    'cancelled' => const CancelledStatus(),
    'refunded' => const RefundedStatus(),
    _ => UnknownStatus(key ?? ''),
  };
}


final class PendingStatus extends OrderStatus {
  const PendingStatus() : super('pending');

  @override
  bool get isTrackable => true;

  @override
  bool get isCancellable => true;
}


final class AcceptedStatus extends OrderStatus {
  const AcceptedStatus() : super('accepted');

  @override
  bool get isTrackable => true;

  @override
  bool get isCancellable => true;
}


final class PreparingStatus extends OrderStatus {
  const PreparingStatus() : super('preparing');

  @override
  bool get isTrackable => true;
}


final class ReadyStatus extends OrderStatus {
  const ReadyStatus() : super('ready');

  @override
  bool get isTrackable => true;
}


final class OnTheWayStatus extends OrderStatus {
  const OnTheWayStatus() : super('on_the_way');

  @override
  bool get isTrackable => true;
}


final class DeliveredStatus extends OrderStatus {
  const DeliveredStatus() : super('delivered');
}


final class CancelledStatus extends OrderStatus {
  const CancelledStatus() : super('cancelled');
}


final class RefundedStatus extends OrderStatus {
  const RefundedStatus() : super('refunded');
}


final class UnknownStatus extends OrderStatus {
  const UnknownStatus(super.apiKey);
}
