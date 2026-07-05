import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class StoreDiscountCouponItem extends StatelessWidget {
  const StoreDiscountCouponItem({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: 325,
      height: 130,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.brCircular16,
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 77,
                height: double.infinity,
                alignment: Alignment.center,
                color: colors.primaryContainer,
                child: Text(
                  '20%',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.style20Bold.copyWith(
                    color: colors.onSecondaryFixedVariant,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.scrim,
                        colors.surfaceContainerHighest,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 16,
                            top: 12,
                            bottom: 12,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 6,
                            children: [
                              Text(
                                'Discount Coupon',
                                style: AppTextStyles.style16Medium.copyWith(
                                  color: colors.primaryContainer,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 2,
                                children: [
                                  Text(
                                    'From January 10 to January 31, 2026',
                                    maxLines: 1,
                                    style: AppTextStyles.style10Regular.copyWith(
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Minimum purchase 1',
                                    maxLines: 1,
                                    style: AppTextStyles.style12Regular.copyWith(
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.onSurfaceVariant,
                                  borderRadius: AppBorderRadius.brCircular30,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 4,
                                  children: [
                                    Text(
                                      'ST-V2586',
                                      style: AppTextStyles.style12Regular
                                          .copyWith(
                                            color: colors.primaryContainer,
                                          ),
                                    ),
                                    Icon(
                                      Icons.copy_rounded,
                                      size: 16,
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
                          child: Assets.media.images.svg.appLogo.svg(
                            height: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 51.5,
            top: -16,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 51.5,
            bottom: -16,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
