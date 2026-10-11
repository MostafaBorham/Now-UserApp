import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/ticket_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';

class DiscountCard extends StatelessWidget {
  const DiscountCard({
    super.key,
    required this.coupon,
    this.dark = false,
    this.onCopy,
  });

  final CouponModel coupon;
  final bool dark;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    // `type` is the backend's enum value, spaces and all.
    final String scope = switch (coupon.type) {
      'Public' => LangKeys.discountOnAllStores.tr(),
      'Specific Category' => LangKeys.discountOnSelectedCategoriesKey.tr(),
      'Specific Products' => LangKeys.discountOnSelectedProductsKey.tr(),
      _ => '',
    };

    final String code = coupon.code ?? '';

    final Color valuePanel = dark
        ? context.colors.surfaceBright
        : context.colors.surface;

    final LinearGradient bodyGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: dark
          ? <Color>[
              context.colors.secondary100.withValues(alpha: 0.2),
              context.colors.surfaceContainerHighest.withValues(alpha: 0.2),
            ]
          : <Color>[
              context.colors.primary100.withValues(alpha: 0.2),
              context.colors.primary200.withValues(alpha: 0.2),
            ],
    );
    final Color percentColor = dark
        ? context.colors.surface
        : context.colors.primaryContainer;
    final Color scopeColor = dark
        ? context.colors.white
        : context.colors.tertiaryContainer;

    // The whole ticket copies the code, not only its pill (BUG-042).
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onCopy,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return PhysicalShape(
            clipper: TicketClipper(textDirection: Directionality.of(context)),
            clipBehavior: Clip.antiAlias,
            color: bodyGradient.colors.first,
            elevation: 1.5,
            shadowColor: const Color(0x14000000),
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: bodyGradient),
              child: AspectRatio(
                aspectRatio: 2.2,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: double.infinity,
                        color: valuePanel,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // A fixed-amount coupon is money, not a percent:
                              // it read "20%" for 20 SAR off.
                              if (coupon.isPercentage ?? true)
                                RichText(
                                  text: TextSpan(
                                    text:
                                        '${formatDouble(coupon.discountValue)}',
                                    style: TextStyle(
                                      fontSize: 40,
                                      height: 1,
                                      fontWeight: FontWeight.w800,
                                      color: percentColor,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '%',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: percentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                NewPriceWidget(
                                  color: percentColor,
                                  price: formatMoney(coupon.discountValue),
                                  size: 32,
                                  fontWeight: FontWeight.w800,
                                ),
                              const SizedBox(height: 6),
                              Text(
                                scope,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: scopeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 5,
                          children: [
                            Text(
                              LangKeys.discountTitle.tr(),
                              style: TextStyle(
                                fontSize: constraints.maxWidth * 0.05,
                                fontWeight: FontWeight.w500,
                                color: context.colors.primaryContainer,
                              ),
                            ),
                            Text(
                              '${LangKeys.fromKey.tr()} ${context.getLocalizedApiDate(apiDateTimeStamp: coupon.startsAt)} ${LangKeys.toKey.tr()} ${context.getLocalizedApiDate(apiDateTimeStamp: coupon.expiresAt)}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: constraints.maxWidth * 0.035,
                                color: context.colors.neutral500,
                              ),
                            ),
                            Text(
                              '${LangKeys.discountMinPurchase.tr()} ${formatMoney(coupon.minOrderValue)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: constraints.maxWidth * 0.035,
                                color: context.colors.neutral500,
                              ),
                            ),
                            _CodeChip(code: code),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: 14,
                        start: 4,
                      ),
                      child: Center(
                        child: Assets.media.images.svg.logoVertical.svg(
                          height: 90,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CodeChip extends StatelessWidget {
  const _CodeChip({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, con) {
        return Container(
          width: con.maxWidth * 0.6,
          height: con.maxWidth * 0.2,
          decoration: BoxDecoration(
            color: context.colors.primary100,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 3,
              children: [
                Assets.media.images.svg.copy.svg(
                  width: con.maxWidth * 0.1,
                  height: con.maxWidth * 0.1,
                ),
                SizedBox(
                  width: con.maxWidth * 0.37,
                  child: Text(
                    code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: con.maxWidth * 0.08,
                      fontWeight: FontWeight.w400,
                      color: context.colors.primaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
