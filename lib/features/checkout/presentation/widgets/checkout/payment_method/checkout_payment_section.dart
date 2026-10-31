import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/selected_payment_card_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/choose_payment_method.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/payment_methods_card.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';

/// Picks the payment widget that matches the customer's cards: the saved-cards
/// list once they have any, otherwise the red "choose a method" prompt that
/// routes to the add-card screen.
///
/// The cards are [checkoutCardsProvider]'s, so a card added, edited or deleted
/// from here shows up as soon as the wallet's list reloads — whatever the
/// checkout preview says meanwhile.
class CheckoutPaymentSection extends ConsumerWidget {
  const CheckoutPaymentSection({super.key});

  void _addCard(BuildContext context) =>
      context.pushNamed(AppRoutes.addPaymentCard);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CardPaymentModel> cards = ref.watch(checkoutCardsProvider);

    return cards.isEmpty
        ? ChoosePaymentMethod(onTap: () => _addCard(context))
        : PaymentMethodsCard(
            cards: cards,
            onAddCard: () => _addCard(context),
          );
  }
}
