import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/home/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/price_with_currency.dart';

class WalletHistoryItem extends StatelessWidget {
  const WalletHistoryItem({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12,horizontal: 20),
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.05),
        borderRadius: AppBorderRadius.brCircular30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 12,
        children: [
          Row(
            spacing: 12,
            children: [
              CircularBrandLogo(radius: 20.sp, logoUrl: 'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    'Shaworma',
                    style: AppTextStyles.style14SemiBold.copyWith(
                      color: colors.onSecondary,
                    ),
                  ),
                  AutoSizeText(
                    'end in 26-04-2026',
                    style: AppTextStyles.style12Medium.copyWith(
                      color: colors.onPrimaryFixed.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 4,horizontal: 10),
            decoration: BoxDecoration(
                color: colors.errorContainer.withValues(alpha: 0.1),
                borderRadius: AppBorderRadius.brCircular30.r
            ),
            child: Center(child: AutoSizeText('Refunded',style: AppTextStyles.style12Medium.copyWith(color: colors.errorContainer),)),
          ),
          PriceWithCurrency(color: colors.error, price: '-10'),
        ],
      ),
    );
  }
}
