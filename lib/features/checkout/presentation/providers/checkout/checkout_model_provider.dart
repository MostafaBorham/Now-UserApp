import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';

/// Exposes the resolved [CheckoutModel] to the checkout screen subtree, or
/// `null` while the draft is still in flight.
///
/// It has no default implementation — the checkout screen overrides it in a
/// [ProviderScope] with a *derived* provider that watches `checkoutProvider`
/// and yields its `valueOrNull`. Deriving it (instead of overriding with a
/// plain value) is what keeps the screen from rebuilding wholesale when the
/// draft resolves or refreshes: the scope widget is built once, and only the
/// descendants that watch the slice they need — via
/// `ref.watch(checkoutModelProvider.select(...))` — are rebuilt.
///
/// Being nullable is deliberate: only the store cards and the invoice summary
/// show a loading state, so every other widget reads this provider before the
/// draft exists and must render its own empty/default copy.
final checkoutModelProvider = Provider.autoDispose<CheckoutModel?>((ref) {
  throw UnimplementedError();
});
