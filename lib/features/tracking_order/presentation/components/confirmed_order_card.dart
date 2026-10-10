import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

/// Order summary card shown on the Order Confirmed screen: a thumbnail, the
/// order number & price, the awaiting-confirmation line, status chips and a
/// "Track Order" CTA.
///
/// The just-confirmed orders are always pending, so this mirrors the shape of
/// the my-orders list item ([OrderListItem]) in its pending state.
class ConfirmedOrderCard extends StatelessWidget {
  const ConfirmedOrderCard({
    super.key,
    required this.orderNumber,
    required this.price,
    required this.itemsCount,
    required this.imageUrl,
    this.onTrack,
  });

  final String orderNumber;
  final String price;
  final int itemsCount;
  final String imageUrl;
  final VoidCallback? onTrack;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
        borderRadius: AppBorderRadius.brCircular16,
        boxShadow: [
          BoxShadow(
            color: colors.neutral500.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: AppBorderRadius.brCircular12,
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: AppCachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            textDirection: TextDirection.ltr,
                            orderNumber,
                            style: AppTextStyles.style18SemiBold.copyWith(
                              color: colors.black,
                            ),
                          ),
                        ),
                        NewPriceWidget(
                          color: colors.primary500Main,
                          price: price,
                          size: 14,
                        ),
                      ],
                    ),
                    4.hSpace,
                    AutoSizeText(
                      LangKeys.awaitingOrderConfirmationKey.tr(),
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.neutral500,
                      ),
                    ),
                    10.hSpace,
                    Row(
                      children: [
                        _Chip(
                          label: LangKeys.itemsCountKey.plural(itemsCount),
                          background: colors.neutral500.withValues(alpha: 0.1),
                          textColor: colors.black,
                        ),
                        8.wSpace,
                        Flexible(
                          child: _Chip(
                            label: LangKeys.pendingKey.tr(),
                            background: colors.tertiaryFixed,
                            textColor: colors.onErrorContainer,
                          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppBorderRadius.brCircular20,
      ),
      child: AutoSizeText(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.style14Regular.copyWith(color: textColor),
      ),
    );
  }
}
