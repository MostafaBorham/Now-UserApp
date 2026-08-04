import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';

class StoreDetailsBrandInfoCard extends StatelessWidget {
  const StoreDetailsBrandInfoCard({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: colors.onPrimary,
        borderRadius: AppBorderRadius.brCircular20,
        boxShadow: [
          BoxShadow(
            color: colors.onSecondary.withValues(
              alpha: 0.08,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        spacing: 8,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  LangKeys.sampleBrandCategoryKey.tr(),
                  style: AppTextStyles.style12Medium.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  LangKeys.sampleBrandNameKey.tr(),
                  style: AppTextStyles.style20Bold.copyWith(
                    color: colors.onTertiaryFixed,
                  ),
                ),
                Text(
                  LangKeys.sampleBrandDescriptionKey.tr(),
                  maxLines: 5,
                  style: AppTextStyles.style14Regular.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 16,
                    children: [
                      Text(
                        '4.8 (2.5${LangKeys.thousandSuffixKey.tr()})',
                        style: TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w400,
                            fontSize: 15
                        ),
                      ),
                      Row(
                        spacing: 3,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) => Assets.media.images.svg.starIcon.svg(
                          colorFilter: ColorFilter.mode(colors.onSecondaryContainer, BlendMode.srcIn),
                          width: 15
                        ),),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Divider(
              color: colors.surfaceContainerLow,
              height: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              spacing: 35,
              children: [
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  spacing: 4,
                  children: [
                    Row(
                      textDirection: TextDirection.ltr,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        OldPriceWidget(
                          color: colors.inversePrimary,
                          price: '13',
                          size: 14,
                        ),
                        Container(
                          padding: const EdgeInsets.all(
                            6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.errorContainer.withValues(alpha: 0.8),
                            borderRadius:
                            BorderRadiusGeometry.circular(
                              16,
                            ),
                          ),
                          child: Text(
                            '-27%',
                            textDirection: TextDirection.ltr,
                            style: AppTextStyles
                                .style12SemiBold
                                .copyWith(
                              color: colors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    NewPriceWidget(
                      color: colors.onSecondary,
                      price: '10',
                      size: 28,
                    ),
                  ],
                ),
                Expanded(
                  child: Material(
                    elevation: 10,
                    color: Colors.transparent,
                    shadowColor: colors.secondaryFixedDim
                        .withValues(alpha: 0.3),
                    child: PrimaryAppPrefixIconButton(
                      title: LangKeys.addToCartKey.tr(),
                      buttonColor: colors.secondaryFixedDim,
                      prefixIcon: ReverseWidget(
                        child: Assets
                            .media
                            .images
                            .svg
                            .shoppingCartIcon
                            .svg(width: 20),
                      ),
                      buttonRadius: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}