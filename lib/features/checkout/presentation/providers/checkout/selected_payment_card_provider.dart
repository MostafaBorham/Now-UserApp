import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The saved card chosen to pay for this checkout, or `null` to fall back to the
/// preview's default card (see `CheckoutModel.resolveDefaultCard`).
///
/// Only matters while the wallet toggle is off — the confirm request then sends
/// `payment_method: card` with this id (the backend prohibits a card id for the
/// wallet/cod methods). autoDispose, so every checkout starts back at the
/// default card.
final selectedPaymentCardProvider = StateProvider.autoDispose<int?>(
  (Ref ref) => null,
);
