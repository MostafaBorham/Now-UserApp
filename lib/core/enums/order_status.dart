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

  /// Whether the order has reached a state the customer can rate — the terminal
  /// `delivered` and `closed` states only. Keyed off [apiKey] so it also covers
  /// `closed`, which the API sends but the hierarchy doesn't model, and lives
  /// here so the rule is defined once instead of re-checked per screen.
  bool get isRateable => apiKey == 'delivered' || apiKey == 'closed';

  /// Maps the API `status` key onto its [OrderStatus]. A `null`, empty, or
  /// unrecognized key resolves to [UnknownStatus] carrying the raw value.
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
