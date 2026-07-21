import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';

/// Exposes the resolved [CheckoutModel] to the checkout screen subtree.
///
/// It has no default implementation — it must be overridden with the concrete
/// model via a [ProviderScope] once the checkout draft has loaded. Descendant
/// widgets then read it synchronously with `ref.watch(checkoutModelProvider)`
/// without touching the [AsyncValue].
final checkoutModelProvider = Provider.autoDispose<CheckoutModel>((ref) {
  throw UnimplementedError();
});
