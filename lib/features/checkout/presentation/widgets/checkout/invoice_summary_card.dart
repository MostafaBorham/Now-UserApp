import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
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

    // Every figure is the server's: the checkout is re-priced with the address,
    // tip and applied codes whenever they change, so nothing is patched in here
    // — a local subtraction can't know the tax the discount also removes.
    final double discount = orderGroup.discount;
    final double total = orderGroup.total;

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
            style: AppTextStyles.style16Bold.copyWith(
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
                      style: AppTextStyles.style14SemiBold.copyWith(
                        color: colors.black,
                      ),
                    ),
                  ),
                  NewPriceWidget(
                    color: colors.black,
                    price: formatMoney(orderGroup.subtotal),
                    size: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      LangKeys.vatFivePercentKey.tr(),
                      style: AppTextStyles.style14SemiBold.copyWith(
                        color: colors.black,
                      ),
                    ),
                  ),
                  NewPriceWidget(
                    color: colors.black,
                    price: formatMoney(orderGroup.tax),
                    size: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      LangKeys.deliveryFeesKey.tr(),
                      style: AppTextStyles.style14SemiBold.copyWith(
                        color: colors.black,
                      ),
                    ),
                  ),
                  NewPriceWidget(
                    color: colors.black,
                    price: formatMoney(orderGroup.deliveryFee),
                    size: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              if (orderGroup.driverTip > 0)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        LangKeys.driverTipKey.tr(),
                        style: AppTextStyles.style14SemiBold.copyWith(
                          color: colors.black,
                        ),
                      ),
                    ),
                    NewPriceWidget(
                      color: colors.black,
                      price: formatMoney(orderGroup.driverTip),
                      size: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              if (discount > 0)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        LangKeys.discountLabelKey.tr(),
                        style: AppTextStyles.style14SemiBold.copyWith(
                          color: colors.black,
                        ),
                      ),
                    ),
                    NewPriceWidget(
                      color: colors.errorContainer,
                      price: formatMoney(discount),
                      size: 15,
                      fontWeight: FontWeight.w600,
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
                  style: AppTextStyles.style16Bold.copyWith(
                    color: colors.black,
                  ),
                ),
              ),
              NewPriceWidget(
                color: colors.primary500Main,
                price: formatMoney(total),
                size: 20,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
