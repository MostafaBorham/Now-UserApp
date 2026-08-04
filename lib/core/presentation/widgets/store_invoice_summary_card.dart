import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
        color: colors.neutral500.withValues(alpha: 0.15),
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
                    price: '${subtotal ?? 0}',
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
                    price: '${tax ?? 0}',
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
                    price: '${deliveryFee ?? 0}',
                    size: 13,
                  ),
                ],
              ),
              if((discount??0)>0) Row(
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
                    price: '${discount ?? 0}',
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
