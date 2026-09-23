import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';

class StoreInvoiceSummaryCard extends StatelessWidget {
  const StoreInvoiceSummaryCard({
    super.key,
    this.subtotal,
    this.tax,
    this.deliveryFee,
    this.discount,
  });

  final double? subtotal;
  final double? tax;
  final double? deliveryFee;
  final double? discount;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.neutral500.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            LangKeys.storeInvoiceSummaryKey.tr(),
            style: AppTextStyles.style16Medium.copyWith(
              color: colors.tertiaryContainer,
            ),
          ),
          Column(
            spacing: 8,
            children: [
              if ((subtotal ?? 0) > 0)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                      fontWeight: FontWeight.w700,
                      color: colors.black,
                      price: formatMoney(subtotal),
                      size: 14,
                    ),
                  ],
                ),
              if ((tax ?? 0) > 0)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        LangKeys.vatKey.tr(),
                        style: AppTextStyles.style14Regular.copyWith(
                          color: colors.black,
                        ),
                      ),
                    ),
                    NewPriceWidget(
                      fontWeight: FontWeight.w700,
                      color: colors.black,
                      price: formatMoney(tax),
                      size: 14,
                    ),
                  ],
                ),
              if ((deliveryFee ?? 0) > 0)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                      fontWeight: FontWeight.w700,
                      color: colors.black,
                      price: formatMoney(deliveryFee),
                      size: 14,
                    ),
                  ],
                ),
              if ((discount ?? 0) > 0)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                      fontWeight: FontWeight.w700,
                      color: colors.errorContainer,
                      price: formatMoney(discount),
                      size: 14,
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
