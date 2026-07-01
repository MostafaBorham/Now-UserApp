import 'package:easy_localization/easy_localization.dart' as easy_locale;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/common/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/common/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/common/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/common/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/common/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/effects/white_gradient_overlay_effect.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/price/old_price_widget.dart';

/// A rich product card used inside the "Most Popular" horizontal slider.
///
/// Dummy/static content is hardcoded inline for fast UI iteration; real data
/// will be wired in later.
class MostPopularSliderItemCard extends StatelessWidget {
  const MostPopularSliderItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: colors.onSurface.withValues(alpha: 0.3), // #00000014
          offset: const Offset(0, 4),
          blurRadius: 10,
          spreadRadius: 0,
        )],
        border: Border.all(
          color: colors.onSurface.withValues(alpha: 0.2),
          width: 1.5
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Expanded(child: _imageSection(colors)),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              spacing: 12,
              children: [
                _titleAndPriceSection(colors),
                _ratingRow(colors),
                PrimaryAppPrefixIconButton(
                  title: context.tr(LangKeys.addToCartKey),
                  buttonRadius: 16,
                  buttonColor: colors.primaryFixedDim,
                  prefixIcon: Assets.media.images.svg.addToCartIcon.svg(
                    colorFilter: ColorFilter.mode(colors.onPrimary, BlendMode.srcIn),
                  ),
                ),
              ],
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
          imageUrl:
              'https://i.pinimg.com/236x/ea/a7/7c/eaa77cb87594418722bf12af28481fdb.jpg',
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
        ),

        Positioned.fill(
          child: WhiteGradientOverlayEffect(),
        ),
        // Rank badge (top-start)
        PositionedDirectional(
          top: 12.h,
          start: 12.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: colors.onPrimary,
              borderRadius: AppBorderRadius.brCircular30,
              boxShadow: AppBoxShadows.blackBottomShadow2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.media.images.svg.rankIcon.svg(
                  colorFilter: ColorFilter.mode(
                    colors.primaryFixedDim,
                    BlendMode.srcIn,
                  ),
                ),
                6.wSpace,
                Text(
                  '${LangKeys.rankKey.tr()} #1 / Perfumes',
                  style: AppTextStyles.style12SemiBold.copyWith(
                    color: colors.primaryFixedDim,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Discount circle (top-end)
        PositionedDirectional(
          top: 12.h,
          end: 12.w,
          child: Container(
            width: 46.w,
            height: 46.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primaryFixedDim,
              shape: BoxShape.circle,
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '-21%',
                style: AppTextStyles.style12Bold.copyWith(
                  color: colors.onPrimary,
                ),
              ),
            ),
          ),
        ),

        // Feature tags (bottom-start)
        PositionedDirectional(
          bottom: 12.h,
          start: 12.w,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.ltr,
            children: [
              _featureTag(colors, LangKeys.newArrivalKey.tr()),
              8.wSpace,
              _featureTag(colors, LangKeys.exclusiveKey.tr()),
            ],
          ),
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
                style: AppTextStyles.style12Medium.copyWith(
                  color: colors.onSurface,
                  letterSpacing: 1.2,
                ),
              ),
              4.hSpace,
              Text(
                'Valentino Uomo Noir',
                maxLines: 1,
                style: AppTextStyles.style20Bold.copyWith(
                  color: colors.onTertiaryFixed,
                ),
              ),
            ],
          ),
        ),
        8.wSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 4,
          children: [
            NewPriceWidget(color: colors.primaryFixedDim, price: '10'),
            OldPriceWidget(color: colors.onSurface, price: '10'),
          ],
        ),
      ],
    );
  }

  /// Rating, review count and units-sold metadata.
  Widget _ratingRow(ColorScheme colors) {
    return Row(
      children: [
        Assets.media.images.svg.starRate.svg(
          width: 16.w,
          height: 16.w,
          colorFilter: ColorFilter.mode(
            colors.primaryFixedDim,
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
        5.wSpace,
        Text(
          '(2,841)',
          style: AppTextStyles.style12Regular.copyWith(color: colors.onSurface),
        ),
        8.wSpace,
        Text(
          '·',
          style: AppTextStyles.style14Bold.copyWith(color: colors.onSurface),
        ),
        8.wSpace,
        Text(
          textDirection: TextDirection.ltr,
          '12.4k ${LangKeys.soldKey.tr()}',
          style: AppTextStyles.style12Regular.copyWith(color: colors.onSurface),
        ),
      ],
    );
  }
}
