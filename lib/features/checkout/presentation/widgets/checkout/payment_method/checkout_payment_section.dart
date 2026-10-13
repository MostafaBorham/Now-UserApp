import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/choose_payment_method.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/payment_methods_card.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';

/// Picks the payment widget that matches the preview: the saved-cards list once
/// the customer has any, otherwise the red "choose a method" prompt that routes
/// to the add-card screen.
///
/// The cards come straight from the checkout preview
/// (`checkout.payment_cards`), a copy of the customer's saved cards. Every card
/// change — the add-card screen, or the wallet's cards sheet reached through
/// "Top up" — ends by reloading [getMyCardsProvider], so the checkout prices
/// again whenever that reload settles, and the change shows up here.
class CheckoutPaymentSection extends ConsumerWidget {
  const CheckoutPaymentSection({super.key});

  void _addCard(BuildContext context) =>
      context.pushNamed(AppRoutes.addPaymentCard);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<List<CardPaymentModel>>>(getMyCardsProvider, (
      AsyncValue<List<CardPaymentModel>>? previous,
      AsyncValue<List<CardPaymentModel>> next,
    ) {
      // Failed reloads too: the change itself was saved before the reload ran.
      if (previous?.isLoading == true && !next.isLoading) {
        ref.read(checkoutProvider.notifier).refresh();
      }
    });

    final List<CardPaymentModel> cards = ref.watch(
      checkoutModelProvider.select(
        (checkout) => checkout?.paymentCards ?? const <CardPaymentModel>[],
      ),
    );

    return cards.isEmpty
        ? ChoosePaymentMethod(onTap: () => _addCard(context))
        : PaymentMethodsCard(
            cards: cards,
            onAddCard: () => _addCard(context),
          );
  }
}
