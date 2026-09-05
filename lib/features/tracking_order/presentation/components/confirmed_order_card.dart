import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

/// Order summary card shown on the Order Confirmed screen: a thumbnail, the
/// order number & price, delivery date, status chips and a "Track Order" CTA.
class ConfirmedOrderCard extends StatelessWidget {
  const ConfirmedOrderCard({
    super.key,
    this.orderNumber = '#ORD-458921',
    this.price = '20.00',
    this.deliveryDate = 'March 12, 2026',
    this.itemsCount = 5,
    this.imageUrl = fallbackImageUrl,
    this.onTrack,
  });

  /// Placeholder thumbnail used when an order carries no vendor logo.
  static const String fallbackImageUrl =
      'https://www.shutterstock.com/image-photo/various-kinds-fresh-colorful-fruits-260nw-2698161807.jpg';

  final String orderNumber;
  final String price;
  final String deliveryDate;
  final int itemsCount;
  final String imageUrl;
  final VoidCallback? onTrack;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primaryFixed,
        borderRadius: AppBorderRadius.brCircular12,
      ),
      child: Column(
        spacing: 12,
        children: [
          Row(
            children: [
              // The SizedBox is load-bearing: AppCachedNetworkImage's shimmer
              // placeholder falls back to `double.infinity` without an outer
              // bound, which a Row cannot lay out.
              SizedBox(
                width: 86,
                height: 86,
                child: ClipRRect(
                  borderRadius: AppBorderRadius.brCircular8,
                  child: AppCachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 86,
                    height: 86,
                  ),
                ),
              ),
              12.wSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            orderNumber,
                            style: AppTextStyles.style16Medium.copyWith(
                              color: colors.tertiaryContainer,
                            ),
                          ),
                        ),
                        8.wSpace,
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Assets.media.images.svg.realSaudiCurrency.svg(
                              width: 8,
                              height: 9,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                colors.primary500Main,
                                BlendMode.srcIn,
                              ),
                            ),
                            4.wSpace,
                            Text(
                              price,
                              style: AppTextStyles.style14Regular.copyWith(
                                color: colors.primary500Main,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    2.hSpace,
                    Text(
                      '${LangKeys.deliveredOnKey.tr()} $deliveryDate',
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.neutral500,
                      ),
                    ),
                    8.hSpace,
                    Row(
                      spacing: 8,
                      children: [
                        _Chip(
                          label: '$itemsCount ${LangKeys.itemsKey.tr()}',
                          background: colors.onPrimaryContainer,
                          textColor: colors.tertiaryContainer,
                        ),
                        _Chip(
                          label: LangKeys.pendingKey.tr(),
                          background: colors.tertiaryFixed,
                          textColor: colors.onErrorContainer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          PrimaryAppButton(
            title: LangKeys.trackOrderKey.tr(),
            onTap: onTrack,
            titleStyle: AppTextStyles.style14Medium,
            // The design's CTA is a 36px-tall bar, not the default 48px one.
            buttonPadding: 8,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.textColor,
  });

  final String label;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppBorderRadius.brCircular20,
      ),
      child: AutoSizeText(
        label,
        style: AppTextStyles.style14Regular.copyWith(color: textColor),
      ),
    );
  }
}
