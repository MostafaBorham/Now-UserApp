import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class StoreDiscountCouponItem extends StatelessWidget {
  const StoreDiscountCouponItem({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: 300,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: colors.tertiaryFixed,
        borderRadius: AppBorderRadius.brCircular16,
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            alignment: Alignment.center,
            color: colors.primary,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                '20%',
                style: AppTextStyles.style24Bold.copyWith(
                  color: colors.onPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4,
                children: [
                  Text(
                    'Discount Coupon',
                    style: AppTextStyles.style16Medium.copyWith(
                      color: colors.primaryContainer,
                    ),
                  ),
                  AutoSizeText(
                    'From January 10 to January 31, 2026',
                    maxLines: 1,
                    style: AppTextStyles.style10Regular.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  AutoSizeText(
                    'Minimum purchase 1',
                    maxLines: 1,
                    style: AppTextStyles.style12Medium.copyWith(
                      color: colors.onSecondary,
                    ),
                  ),
                  6.hSpace,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.onSurfaceVariant,
                      borderRadius: AppBorderRadius.brCircular6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Text(
                          'ST-V2586',
                          style: AppTextStyles.style12SemiBold.copyWith(
                            color: colors.primaryContainer,
                          ),
                        ),
                        Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: colors.primaryContainer,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: RotatedBox(
              quarterTurns: 3,
              child: Assets.media.images.svg.appOrangeLogo.svg(height: 20),
            ),
          ),
        ],
      ),
    );
  }
}
