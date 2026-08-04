import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/overlay_opacity_widget.dart';

/// A vertical two-tone discount coupon ticket.
///
/// The yellow header shows the discount value and the target store, while the
/// light-green body carries the coupon label, its validity window and the app
/// logo. Two side notches at the colour seam give it the torn-ticket look.
class DiscountCodeItem extends StatelessWidget {
  const DiscountCodeItem({
    super.key,
    this.percentage = '20%',
    this.storeName,
    this.label,
    this.validity,
    this.isDimmed = false,
  });

  final String percentage;
  final String? storeName;
  final String? label;
  final String? validity;
  final bool? isDimmed;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final String resolvedValidity = validity ?? LangKeys.sampleValidityKey.tr();

    return SizedBox(
      width: 120,
      height: 158,
      child: OverlayOpacityWidget(
        disabled: isDimmed!,
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
                          '${LangKeys.inKey.tr()} ${storeName??'Panda Store'}',
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
                    child: LayoutBuilder(
                      builder: (context,con) {
                        return Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [colors.tertiary.withValues(alpha: 0.2),colors.tertiary.withValues(alpha: 0.4),],
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                spacing: 6,
                                children: [
                                  Text(
                                    LangKeys.discountCouponKey.tr(),
                                    maxLines: 1,
                                    style: AppTextStyles.style12Medium.copyWith(
                                      color: colors.primaryContainer,
                                    ),
                                  ),
                                  Text(
                                    resolvedValidity,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.style8Medium.copyWith(
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  Assets.media.images.svg.appLogo.svg(
                                    width: con.maxWidth*0.6
                                  ),
                                ],
                              ),
                            ),
                            Positioned.fill(
                              left: -20,
                              right: -20,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
            // Torn-ticket notches punched into the left/right edges, centred
            // vertically within the green body (matches the Figma geometry).
          ],
        ),
      ),
    );
  }
}
