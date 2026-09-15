import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/choose_payment_method.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/payment_methods_card.dart';

class CheckoutPaymentSection extends ConsumerWidget {
  const CheckoutPaymentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool hasPaymentMethod = ref.watch(
      checkoutModelProvider.select(
        (CheckoutModel? checkout) =>
            (checkout?.orderGroup.paymentMethod ?? '').isNotEmpty,
      ),
    );

    return hasPaymentMethod
        ? const PaymentMethodsCard()
        : ChoosePaymentMethod(
            onTap: () => context.pushNamed(AppRoutes.addPaymentCard),
          );
  }
}
