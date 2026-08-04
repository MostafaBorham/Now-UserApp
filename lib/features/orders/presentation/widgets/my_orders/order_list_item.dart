import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';

class OrderListItem extends ConsumerWidget {
  const OrderListItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
        borderRadius: AppBorderRadius.brCircular16,
        boxShadow: [
          BoxShadow(
            color: colors.neutral500.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 10,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: AppBorderRadius.brCircular12,
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://www.shutterstock.com/image-photo/various-kinds-fresh-colorful-fruits-260nw-2698161807.jpg',
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      '#ORD-458921',
                      style: AppTextStyles.style18SemiBold.copyWith(
                        color: colors.black,
                      ),
                    ),
                    4.hSpace,
                    AutoSizeText(
                      '${LangKeys.deliveredOnKey.tr()} March 12, 2026',
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.neutral500,
                      ),
                    ),
                    10.hSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.neutral500.withValues(alpha: 0.1),
                            borderRadius: AppBorderRadius.brCircular20,
                          ),
                          child: AutoSizeText(
                            '5 ${LangKeys.itemsKey.tr()}',
                            style: AppTextStyles.style14Regular.copyWith(
                              color: colors.black,
                            ),
                          ),
                        ),

                        8.wSpace,
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.onSecondaryFixed.withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: AppBorderRadius.brCircular20,
                          ),
                          child: AutoSizeText(
                            LangKeys.pendingKey.tr(),
                            style: AppTextStyles.style14Regular.copyWith(
                              color: colors.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    Assets.media.images.svg.realSaudiCurrency.svg(
                      width: 12,
                      height: 12,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        colors.primary500Main,
                        BlendMode.srcIn,
                      ),
                    ),
                    Text(
                      '20.00',
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.primary500Main,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 4.3,
                  child: PrimaryAppButton( title: LangKeys.viewDetailsKey.tr(),buttonPadding : 8, onTap: () {
                    context.pushNamed(AppRoutes.orderDetailsScreen);
                  },),
                ),
              ),
              12.wSpace,
              Expanded(
                child: AspectRatio(
                  aspectRatio: 4.3,
                  child: UnPrimaryButton( title: LangKeys.trackOrderKey.tr(),buttonPadding : 8, onTap: () {
                    context.pushNamed(AppRoutes.trackOrderScreen);
                  },),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
