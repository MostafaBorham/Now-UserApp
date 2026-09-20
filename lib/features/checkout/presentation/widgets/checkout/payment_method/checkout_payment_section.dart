import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/choose_payment_method.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/payment_methods_card.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';

/// Picks the payment widget that matches the preview: the saved-cards list once
/// the customer has any, otherwise the red "choose a method" prompt that routes
/// to the add-card screen.
///
/// The cards come straight from the checkout preview
/// (`checkout.payment_cards`) — re-previewing (which the screen already does)
/// brings a fresh list, so there is no separate cards provider to keep in sync.
class CheckoutPaymentSection extends ConsumerWidget {
  const CheckoutPaymentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CardPaymentModel> cards = ref.watch(
      checkoutModelProvider.select(
        (checkout) => checkout?.paymentCards ?? const <CardPaymentModel>[],
      ),
    );

    return cards.isEmpty
        ? ChoosePaymentMethod(
            onTap: () => context.pushNamed(AppRoutes.addPaymentCard),
          )
        : PaymentMethodsCard(cards: cards);
  }
}
