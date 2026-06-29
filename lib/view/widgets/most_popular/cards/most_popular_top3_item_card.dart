import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/effects/white_gradient_overlay_effect.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/old_price_widget.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/previous_price_with_currency.dart';

/// A compact horizontal product card used inside the "Most Popular" filters list.
///
/// Static/dummy content is hardcoded inline for fast UI iteration; real data
/// will be wired in later.
class MostPopularTop3ItemCard extends StatelessWidget {
  const MostPopularTop3ItemCard({super.key,});
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: colors.scrim,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.2), // #00000014
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: colors.onSurface.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Expanded(flex: 3, child: _imageSection(colors)),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 0,
                children: [
                  _titleAndPriceSection(colors),
                  _ratingRow(colors),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Assets.media.images.svg.realSaudiCurrency.svg(
                                fit: BoxFit.contain,
                                width: 16,
                                colorFilter: ColorFilter.mode(
                                  colors.outlineVariant,
                                  BlendMode.srcIn,
                                ),
                              ),
                              4.wSpace,
                              Text(
                                '10',
                                style: AppTextStyles.style24Bold.copyWith(
                                  color: colors.outlineVariant,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                          OldPriceWidget(color: colors.onSurface, price: '10'),
                        ],
                      ),
                      FloatingActionButton(
                        onPressed: () {},
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(17),
                        ),
                        mini: true,
                        backgroundColor: colors.outlineVariant,
                        child: Text(
                          '+',
                          style: AppTextStyles.style20SemiBold.copyWith(
                            color: colors.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Product image with rank badge, discount circle and feature tags.
  Widget _imageSection(ColorScheme colors) {
    return Stack(
      children: [
        AppCachedNetworkImage(
          imageUrl: 'https://www.britinsurance.com/media/q1vfhqrh/brit-sneakers-01.png?width=768&height=902&v=1dad8ecde3c5bb0',
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
        ),
        Positioned.fill(child: WhiteGradientOverlayEffect()),
        PositionedDirectional(
          top: 12.h,
          start: 12.w,
          child: Container(
            width: 28.w,
            height: 28.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              shape: BoxShape.circle,
            ),
            child: Text(
              '#3',
              style: AppTextStyles.style10Medium.copyWith(
                color: colors.onPrimary,
              ),
            ),
          ),
        ),
        PositionedDirectional(
          top: 12.h,
          end: 12.w,
          child: Container(
            width: 40,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.onPrimary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '-22%',
              style: AppTextStyles.style10Medium.copyWith(
                color: colors.outlineVariant,
              ),
            ),
          ),
        ),
        PositionedDirectional(
          bottom: 12.h,
          end: 12.w,
          child: Icon(Icons.favorite_outline, color: colors.onSurface),
        ),
      ],
    );
  }

  Widget _featureTag(ColorScheme colors, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: colors.onPrimary,
        borderRadius: AppBorderRadius.brCircular30,
        boxShadow: AppBoxShadows.blackBottomShadow2,
      ),
      child: Text(
        label,
        style: AppTextStyles.style12SemiBold.copyWith(
          color: colors.onTertiaryFixed,
        ),
      ),
    );
  }

  /// Brand + product name on the start side, current/previous price on the end.
  Widget _titleAndPriceSection(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VALENTINO',
                style: AppTextStyles.style10Regular.copyWith(
                  color: colors.onSurface,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Valentino Uomo Noir',
                maxLines: 1,
                style: AppTextStyles.style14Bold.copyWith(
                  color: colors.onTertiaryFixed,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Rating, review count and units-sold metadata.
  Widget _ratingRow(ColorScheme colors) {
    return Row(
      children: [
        Assets.media.images.svg.starRate.svg(
          width: 12.w,
          height: 12.w,
          colorFilter: ColorFilter.mode(
            colors.onSecondaryContainer,
            BlendMode.srcIn,
          ),
        ),
        5.wSpace,
        Text(
          '4.9',
          style: AppTextStyles.style14SemiBold.copyWith(
            color: colors.onTertiaryFixed,
          ),
        ),
      ],
    );
  }
}
