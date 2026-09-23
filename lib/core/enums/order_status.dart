/// The lifecycle state of an order, modeled as a sealed hierarchy so callers
/// branch over an exhaustive, type-safe set instead of loose raw strings.
///
/// Parse the API's machine key (`pending`, `on_the_way`, …) with
/// [OrderStatus.fromKey]; unknown/absent keys fall back to [UnknownStatus].
/// Behavioural questions (e.g. "can this order be tracked?") live here as
/// getters — [isTrackable] — so the answer is defined once and reused
/// everywhere, never re-hardcoded at a call site.
sealed class OrderStatus {
  const OrderStatus(this.apiKey);

  /// The raw machine key the API sends in the `status` field.
  final String apiKey;

  /// Whether the order is still in flight and therefore exposes live tracking.
  /// Only the pre-delivery states ([PendingStatus] → [OnTheWayStatus]) override
  /// this to `true`; terminal states (delivered / cancelled / refunded) and
  /// [UnknownStatus] stay `false`.
  bool get isTrackable => false;

  /// Whether the customer can still cancel the order. Only the pre-preparation
  /// states ([PendingStatus], [AcceptedStatus]) override this to `true`; once
  /// the vendor starts preparing ([PreparingStatus] onward) it's too late to
  /// cancel, so every other state stays `false`.
  bool get isCancellable => false;

  /// Whether the order has reached a state the customer can rate — delivered
  /// (which `closed` maps onto) only. Lives here so the rule is defined once
  /// instead of re-checked per screen.
  bool get isRateable => this is DeliveredStatus;

  /// Whether the order's invoice can be printed/downloaded — delivered (which
  /// `closed` maps onto) only.
  bool get hasInvoice => this is DeliveredStatus;

  /// Maps the API `status` key onto its [OrderStatus]. A `null`, empty, or
  /// unrecognized key resolves to [UnknownStatus] carrying the raw value.
  ///
  /// The backend has more states than the customer needs told apart, so four
  /// map onto the one they behave as: the courier waiting at the store is
  /// still `ready`, a picked-up order is `on_the_way`, a settled one
  /// (`closed`) is `delivered`, a vendor-refused one (`rejected`) is
  /// `cancelled`. Left unmodelled they became [UnknownStatus], and tracking
  /// went blank between pickup and the road. The chip still shows the
  /// server's own label (`order_status`), so nothing is misnamed.
  static OrderStatus fromKey(String? key) => switch (key) {
    'pending' => const PendingStatus(),
    'accepted' => const AcceptedStatus(),
    'preparing' => const PreparingStatus(),
    'ready' || 'arrived_store' => const ReadyStatus(),
    'on_the_way' || 'picked_up' => const OnTheWayStatus(),
    'delivered' || 'closed' => const DeliveredStatus(),
    'cancelled' || 'rejected' => const CancelledStatus(),
    'refunded' => const RefundedStatus(),
    _ => UnknownStatus(key ?? ''),
  };
}

/// Placed, awaiting the vendor's confirmation.
final class PendingStatus extends OrderStatus {
  const PendingStatus() : super('pending');

  @override
  bool get isTrackable => true;

  @override
  bool get isCancellable => true;
}

/// Confirmed by the vendor.
final class AcceptedStatus extends OrderStatus {
  const AcceptedStatus() : super('accepted');

  @override
  bool get isTrackable => true;

  @override
  bool get isCancellable => true;
}

/// The vendor is preparing the order.
final class PreparingStatus extends OrderStatus {
  const PreparingStatus() : super('preparing');

  @override
  bool get isTrackable => true;
}

/// Prepared and waiting for pickup.
final class ReadyStatus extends OrderStatus {
  const ReadyStatus() : super('ready');

  @override
  bool get isTrackable => true;
}

/// Out for delivery with the driver.
final class OnTheWayStatus extends OrderStatus {
  const OnTheWayStatus() : super('on_the_way');

  @override
  bool get isTrackable => true;
}

/// Delivered to the customer (terminal).
final class DeliveredStatus extends OrderStatus {
  const DeliveredStatus() : super('delivered');
}

/// Cancelled before delivery (terminal).
final class CancelledStatus extends OrderStatus {
  const CancelledStatus() : super('cancelled');
}

/// Refunded after cancellation/return (terminal).
final class RefundedStatus extends OrderStatus {
  const RefundedStatus() : super('refunded');
}

/// Any key the app doesn't model yet; carries the raw value for display/logging.
final class UnknownStatus extends OrderStatus {
  const UnknownStatus(super.apiKey);
}
