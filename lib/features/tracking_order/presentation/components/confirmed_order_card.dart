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
    this.imageUrl =
        'https://www.shutterstock.com/image-photo/various-kinds-fresh-colorful-fruits-260nw-2698161807.jpg',
    this.onTrack,
  });

  final String orderNumber;
  final String price;
  final String deliveryDate;
  final int itemsCount;
  final String imageUrl;
  final VoidCallback? onTrack;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        spacing: 12,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: ClipRRect(
                  borderRadius: AppBorderRadius.brCircular12,
                  child: AppCachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 72,
                    height: 72,
                  ),
                ),
              ),
              12.wSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            orderNumber,
                            style: AppTextStyles.style18SemiBold.copyWith(
                              color: colors.onSecondary,
                            ),
                          ),
                        ),
                        8.wSpace,
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Assets.media.images.svg.realSaudiCurrency.svg(
                              width: 12,
                              height: 12,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                colors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            5.wSpace,
                            Text(
                              price,
                              style: AppTextStyles.style14Regular.copyWith(
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    6.hSpace,
                    Text(
                      '${LangKeys.deliveredOnKey.tr()} $deliveryDate',
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    10.hSpace,
                    Row(
                      spacing: 8,

                      children: [
                        _Chip(
                          label: '$itemsCount ${LangKeys.itemsKey.tr()}',
                          background: colors.onSurface.withValues(alpha: 0.1),
                          textColor: colors.onSecondary,
                        ),
                        _Chip(
                          label: LangKeys.pendingKey.tr(),
                          background: colors.onSecondaryFixed.withValues(
                            alpha: 0.4,
                          ),
                          textColor: colors.onErrorContainer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          PrimaryAppButton(title: LangKeys.trackOrderKey.tr(), onTap: onTrack),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
