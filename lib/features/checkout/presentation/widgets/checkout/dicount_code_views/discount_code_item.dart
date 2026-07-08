import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// A vertical two-tone discount coupon ticket.
///
/// The yellow header shows the discount value and the target store, while the
/// light-green body carries the coupon label, its validity window and the app
/// logo. Two side notches at the colour seam give it the torn-ticket look.
class DiscountCodeItem extends StatelessWidget {
  const DiscountCodeItem({
    super.key,
    this.percentage = '20%',
    this.storeName = 'In Panda Store',
    this.label = 'Discount Coupon',
    this.validity = 'From January 10 to January 31, 2026',
  });

  final String percentage;
  final String storeName;
  final String label;
  final String validity;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 120,
      height: 158,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                // Yellow header: discount value + store name.
                Container(
                  height: 60,
                  width: double.infinity,
                  alignment: Alignment.center,
                  color: colors.onSecondaryFixedVariant,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 2,
                    children: [
                      Text(
                        percentage,
                        style: AppTextStyles.style20SemiBold.copyWith(
                          color: colors.primaryContainer,
                        ),
                      ),
                      Text(
                        storeName,
                        maxLines: 1,
                        style: AppTextStyles.style12SemiBold.copyWith(
                          color: colors.tertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                // Green body: coupon label, validity window, logo.
                Expanded(
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [colors.onSurfaceVariant, colors.tertiary],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          style: AppTextStyles.style12Medium.copyWith(
                            color: colors.primaryContainer,
                          ),
                        ),
                        Text(
                          validity,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.style8Medium.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                        Assets.media.images.svg.appLogo.svg(width: 44),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Torn-ticket notches punched at the colour seam.
          Positioned(
            left: -7,
            top: 53,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -7,
            top: 53,
            child: Container(
              width: 14,
              height: 14,
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
