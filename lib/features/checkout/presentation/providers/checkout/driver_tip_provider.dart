import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';

/// The driver tip the customer picked; `0` for none.
///
/// autoDispose, kept alive by the checkout screen, so every checkout starts
/// with no tip — as the tip picker does. Previews never carry it: it is added
/// by [tippedCheckoutProvider] and sent only when the order is placed.
final driverTipProvider = StateProvider.autoDispose<double>((Ref ref) => 0);

/// The server's pricing with the picked tip added — what the invoice shows and
/// what placing the order charges. `null` until the checkout loads.
///
/// Watches the priced value only, so a re-price's loading flip, which keeps
/// the same value, recomputes nothing.
final tippedCheckoutProvider = Provider.autoDispose<CheckoutModel?>((Ref ref) {
  final CheckoutModel? checkout = ref.watch(
    checkoutProvider.select(
      (AsyncValue<CheckoutModel?> state) => state.valueOrNull,
    ),
  );
  return checkout?.withTip(ref.watch(driverTipProvider));
});
