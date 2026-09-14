import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/applied_discounts_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';

class InvoiceSummaryCard extends ConsumerWidget {
  const InvoiceSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    // Falls back to the zeroed group so the card stays renderable even outside
    // a resolved draft; in practice [InvoiceSummarySection] only mounts it once
    // the draft is in.
    final OrderGroupModel orderGroup =
        ref.watch(
          checkoutModelProvider.select(
            (CheckoutModel? checkout) => checkout?.orderGroup,
          ),
        ) ??
        const OrderGroupModel();

    // Coupon/voucher apply is a stateless per-vendor calculator that returns
    // only the discount, so the applied discounts are summed here and reflected
    // locally: added to the discount line and subtracted from the total.
    final double appliedDiscount = ref
        .watch(appliedDiscountsProvider)
        .fold<double>(
          0,
          (double sum, AppliedDiscountModel d) => sum + d.discount,
        );
    final double discount = orderGroup.discount + appliedDiscount;
    final double total = orderGroup.total - appliedDiscount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            LangKeys.invoiceSummaryKey.tr(),
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
                      LangKeys.subtotalKey.tr(),
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.black,
                      ),
                    ),
                  ),
                  NewPriceWidget(
                    color: colors.black,
                    price: '${formatDouble(orderGroup.subtotal)}',
                    size: 13,
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      LangKeys.vatFivePercentKey.tr(),
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.black,
                      ),
                    ),
                  ),
                  NewPriceWidget(
                    color: colors.black,
                    price: '${formatDouble(orderGroup.tax)}',
                    size: 13,
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      LangKeys.deliveryFeesKey.tr(),
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.black,
                      ),
                    ),
                  ),
                  NewPriceWidget(
                    color: colors.black,
                    price: '${formatDouble(orderGroup.deliveryFee)}',
                    size: 13,
                  ),
                ],
              ),
              if (discount > 0)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        LangKeys.discountLabelKey.tr(),
                        style: AppTextStyles.style14Regular.copyWith(
                          color: colors.black,
                        ),
                      ),
                    ),
                    NewPriceWidget(
                      color: colors.errorContainer,
                      price: '${formatDouble(discount)}',
                      size: 13,
                    ),
                  ],
                ),
            ],
          ),
          Divider(
            height: 2,
            thickness: 1,
            color: colors.neutral500.withValues(alpha: 0.3),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  LangKeys.totalKey.tr(),
                  style: AppTextStyles.style14SemiBold.copyWith(
                    color: colors.black,
                  ),
                ),
              ),
              NewPriceWidget(
                color: colors.primary500Main,
                price: '${formatDouble(total)}',
                size: 13,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
