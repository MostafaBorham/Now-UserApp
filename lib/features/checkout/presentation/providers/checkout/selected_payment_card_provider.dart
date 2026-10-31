import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';

/// The saved card chosen to pay for this checkout, or `null` to fall back to the
/// default card (see `CheckoutModel.resolveDefaultCard`).
///
/// Only matters while the wallet toggle is off — the confirm request then sends
/// `payment_method: card` with this id (the backend prohibits a card id for the
/// wallet/cod methods). autoDispose, so every checkout starts back at the
/// default card.
final selectedPaymentCardProvider = StateProvider.autoDispose<int?>(
  (Ref ref) => null,
);

/// The usable saved cards checkout offers: the wallet's list, which every card
/// change (the add-card screen, the cards sheet behind "Top up") reloads, and
/// the preview's copy only while that list is reloading or failed.
///
/// Not the preview first: a re-price the server refuses — the store closed
/// meanwhile, the phone went offline — keeps the old preview, so a card added
/// after it would never show.
final checkoutCardsProvider = Provider.autoDispose<List<CardPaymentModel>>((
  Ref ref,
) {
  final List<CardPaymentModel> cards =
      ref.watch(getMyCardsProvider).valueOrNull ??
      ref.watch(
        checkoutProvider.select(
          (AsyncValue<CheckoutModel?> state) => state.valueOrNull?.paymentCards,
        ),
      ) ??
      const <CardPaymentModel>[];
  return <CardPaymentModel>[
    for (final CardPaymentModel card in cards)
      if (card.isUsable) card,
  ];
});
