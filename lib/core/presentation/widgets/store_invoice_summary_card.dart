import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';

class StoreInvoiceSummaryCard extends StatelessWidget {
  const StoreInvoiceSummaryCard({super.key, this.pricing});

  final CartVendorPricingModel? pricing;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            'Store Invoice Summary',
            style: AppTextStyles.style16Medium.copyWith(
              color: colors.tertiaryContainer,
            ),
          ),
          Column(
            spacing: 8,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Subtotal',
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.onSecondary,
                      ),
                    ),
                  ),
                  NewPriceWidget(
                    color: colors.onSecondary,
                    price: '${pricing?.subtotal}',
                    size: 13,
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Vat (5%)',
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.onSecondary,
                      ),
                    ),
                  ),
                  NewPriceWidget(
                    color: colors.onSecondary,
                    price: '${pricing?.tax}',
                    size: 13,
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Delivery Fee',
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.onSecondary,
                      ),
                    ),
                  ),
                  NewPriceWidget(
                    color: colors.onSecondary,
                    price: '${pricing?.deliveryFee}',
                    size: 13,
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Discount',
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.onSecondary,
                      ),
                    ),
                  ),
                  NewPriceWidget(
                    color: colors.errorContainer,
                    price: '${pricing?.discount}',
                    size: 13,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}