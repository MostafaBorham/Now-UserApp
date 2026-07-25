import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';

class DeliveryAddressCard extends ConsumerWidget {
  const DeliveryAddressCard({
    super.key,
  });


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String? address = ref.watch(
      checkoutModelProvider.select(
        (checkout) => checkout.orderGroup.deliveryAddress,
      ),
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Delivery Address',
                style: AppTextStyles.style16Medium.copyWith(
                  color: colors.tertiaryContainer,
                ),
              ),
              InkWell(
                onTap: () => context.pushNamed(AppRoutes.myAddressScreen),
                child: Text(
                  'Edit',
                  style: AppTextStyles.style14Regular.copyWith(
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          Text(
            address ?? 'No Address',
            style: AppTextStyles.style14Regular.copyWith(
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
