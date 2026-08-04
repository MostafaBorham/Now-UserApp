import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';

class StoreDiscountCouponItem extends StatelessWidget {
  const StoreDiscountCouponItem({super.key, required this.coupon});
  final CouponModel coupon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

/*    final double discountValue = coupon.discountValue ?? 0;
    final String discountText = discountValue % 1 == 0
        ? discountValue.toStringAsFixed(0)
        : discountValue.toString();
    final String discountLabel =
        coupon.isPercentage == true ? '$discountText%' : discountText;*/

    final DateTime? startsAt = DateTime.tryParse(coupon.startsAt ?? '');
    final DateTime? expiresAt = DateTime.tryParse(coupon.expiresAt ?? '');
    final loc.DateFormat dateFormat =
        loc.DateFormat.yMMMMd(context.locale.toString());
    final String validityText = [
      if (startsAt != null)
        '${LangKeys.fromKey.tr()} ${dateFormat.format(startsAt)}',
      if (expiresAt != null)
        '${LangKeys.toKey.tr()} ${dateFormat.format(expiresAt)}',
    ].join(' ');

    final double minOrderValue = coupon.minOrderValue ?? 0;
    final String minOrderText = minOrderValue % 1 == 0
        ? minOrderValue.toStringAsFixed(0)
        : minOrderValue.toString();

    return Container(
      width: 325,
      height: 130,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.brCircular16,
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 77,
                height: double.infinity,
                alignment: Alignment.center,
                color: colors.surfaceBright,
                child: Row(
                  textDirection: TextDirection.ltr,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    coupon.isPercentage!? SizedBox() : Assets.media.images.svg.realSaudiCurrency.svg(),
                    Text(
                      '${coupon.discountValue?.toInt()}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.style20Bold.copyWith(
                        color: colors.onSecondaryFixedVariant,
                      ),
                    ),
                    coupon.isPercentage!? Text(
                      '%',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.style20Bold.copyWith(
                        color: colors.onSecondaryFixedVariant,
                      ),
                    ) : SizedBox()
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.surfaceContainerHighest.withValues(alpha: 0.2),
                        colors.surfaceContainerHighest.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 16,
                            top: 12,
                            bottom: 12,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 6,
                            children: [
                              Text(
                                coupon.name ?? LangKeys.discountCouponKey.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.style16Medium.copyWith(
                                  color: colors.primaryContainer,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 2,
                                children: [
                                  if (validityText.isNotEmpty)
                                    Text(
                                      validityText,
                                      maxLines: 1,
                                      style: AppTextStyles.style10Regular.copyWith(
                                        color: colors.onSurface,
                                      ),
                                    ),
                                  Text(
                                    '${coupon.description}',
                                    maxLines: 1,
                                    style: AppTextStyles.style12Regular.copyWith(
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: coupon.code == null
                                    ? null
                                    : () => Clipboard.setData(
                                          ClipboardData(text: coupon.code!),
                                        ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.onSurfaceVariant,
                                    borderRadius: AppBorderRadius.brCircular30,
                                  ),
                                  child: Row(
                                    textDirection: TextDirection.ltr,
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 4,
                                    children: [
                                      Text(
                                        coupon.code ?? '',
                                        style: AppTextStyles.style12Regular
                                            .copyWith(
                                              color: colors.primaryContainer,
                                            ),
                                      ),
                                      Assets.media.images.svg.copyCouponCodeIcon.svg(
                                        width: 16,
                                        colorFilter: ColorFilter.mode(colors.primaryContainer,BlendMode.srcIn)
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Assets.media.images.svg.appLogo.svg(
                            height: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          PositionedDirectional(
            end: 60,
            top: -16,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          PositionedDirectional(
            end: 60,
            bottom: -16,
            child: Container(
              width: 32,
              height: 32,
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
