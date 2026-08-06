import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// Outlined summary card on the Payment Failed screen: the order number and the
/// amount still due.
class OrderAmountCard extends StatelessWidget {
  const OrderAmountCard({
    super.key,
    this.orderNumber = '#ORD-284917',
    this.amount = '20.00',
  });

  final String orderNumber;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: AppBorderRadius.brCircular12,
        border: Border.all(color: colors.neutral200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  LangKeys.orderNumberKey.tr(),
                  style: AppTextStyles.style12Medium.copyWith(
                    color: Color(0xff888888),
                  ),
                ),
              ),
              Text(
                orderNumber,
                style: AppTextStyles.style14Bold.copyWith(
                  color: colors.black,
                ),
              ),
            ],
          ),
          12.hSpace,
          Divider(height: 1, thickness: 1, color: colors.neutral200),
          12.hSpace,
          Row(
            children: [
              Expanded(
                child: Text(
                  LangKeys.amountDueKey.tr(),
                  style: AppTextStyles.style12Medium.copyWith(
                    color: Color(0xff888888),
                  ),
                ),
              ),
              Assets.media.images.svg.realSaudiCurrency.svg(
                width: 12,
                height: 12,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  colors.black,
                  BlendMode.srcIn,
                ),
              ),
              5.wSpace,
              Text(
                amount,
                style: AppTextStyles.style14Regular.copyWith(
                  color: colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
