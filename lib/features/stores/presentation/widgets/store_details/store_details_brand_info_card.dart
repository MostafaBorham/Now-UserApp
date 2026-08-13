import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';

class StoreDetailsBrandInfoCard extends StatelessWidget {
  const StoreDetailsBrandInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        spacing: 8,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                LangKeys.sampleBrandCategoryKey.tr(),
                style: AppTextStyles.style12Regular.copyWith(
                  color: colors.neutral500,
                ),
              ),
              Text(
                LangKeys.sampleBrandNameKey.tr(),
                style: AppTextStyles.style20Bold.copyWith(
                  color: colors.neutral1200,
                ),
              ),
              Text(
                LangKeys.sampleBrandDescriptionKey.tr(),
                maxLines: 5,
                style: AppTextStyles.style14Regular.copyWith(
                  color: colors.neutral500,
                  fontSize: 13,
                  height: 1.7,
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    Text(
                      '4.8 (2.5${LangKeys.thousandSuffixKey.tr()})',
                      style: AppTextStyles.style12Regular.copyWith(
                        color: colors.neutral500,
                      ),
                    ),
                    Row(
                      spacing: 2,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (index) => Assets.media.images.svg.starIcon.svg(
                          colorFilter: ColorFilter.mode(
                            colors.onSecondaryContainer,
                            BlendMode.srcIn,
                          ),
                          width: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: colors.neutral200, height: 20),
          Row(
            spacing: 24,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 4,
                children: [
                  Row(
                    textDirection: TextDirection.ltr,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      OldPriceWidget(
                        color: colors.neutral400,
                        price: '13',
                        size: 14,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colors.errorContainer.withValues(alpha: 0.8),
                          borderRadius: BorderRadiusGeometry.circular(16),
                        ),
                        child: Text(
                          '-27%',
                          textDirection: TextDirection.ltr,
                          style: AppTextStyles.style12SemiBold.copyWith(
                            color: colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  NewPriceWidget(color: colors.black, price: '10', size: 28),
                ],
              ),
              Expanded(
                child: Material(
                  elevation: 10,
                  color: Colors.transparent,
                  shadowColor: colors.secondaryFixedDim.withValues(alpha: 0.3),
                  child: PrimaryAppPrefixIconButton(
                    title: LangKeys.addToCartKey.tr(),
                    buttonColor: colors.secondaryFixedDim,
                    prefixIcon: ReverseWidget(
                      child: Assets.media.images.svg.shoppingCartIcon.svg(
                        width: 20,
                      ),
                    ),
                    buttonRadius: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
