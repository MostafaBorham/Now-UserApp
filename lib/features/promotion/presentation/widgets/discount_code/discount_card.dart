import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/ticket_clipper.dart';

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

  /*  static String _formatAmount(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  static String _formatValidity(String? startsAt, String? expiresAt) {
    final String start = _dateOnly(startsAt);
    final String end = _dateOnly(expiresAt);
    if (start.isEmpty && end.isEmpty) return '';
    return LangKeys.discountValidity.tr(
      namedArgs: {'start': start, 'end': end},
    );
  }

  static String _dateOnly(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    final int tIndex = isoDate.indexOf('T');
    return tIndex == -1 ? isoDate : isoDate.substring(0, tIndex);
  }*/

  @override
  Widget build(BuildContext context) {
    // final String percent = _formatAmount(coupon.discountValue);
    final String scope = coupon.type == 'Public'
        ? LangKeys.discountOnAllStores.tr()
        : (coupon.type ?? '');
    /*    final String validity = _formatValidity(coupon.startsAt, coupon.expiresAt);
    final String minPurchase = LangKeys.discountMinPurchase.tr(
      namedArgs: {'amount': _formatAmount(coupon.minOrderValue)},
    );*/
    final String code = coupon.code ?? '';

    final Color valuePanel = dark
        ? context.colors.surfaceBright
        : context.colors.surface;
    // Body background is a linear gradient — two amber tints when [dark], two
    // mint/green tints otherwise — sourced from the app palette.
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

    return PhysicalShape(
      clipper: TicketClipper(textDirection: Directionality.of(context)),
      clipBehavior: Clip.antiAlias,
      color: bodyGradient.colors.first,
      elevation: 1.5,
      shadowColor: const Color(0x14000000),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: bodyGradient),
        child: AspectRatio(
          aspectRatio: 16 / 6,
          child: Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Container(
                    height: constraints.maxHeight,
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
                          RichText(
                            text: TextSpan(
                              text: '${formatDouble(coupon.discountValue)}',
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
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    spacing: 6,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LangKeys.discountTitle.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: context.colors.primaryContainer,
                        ),
                      ),
                      Text(
                        '${LangKeys.fromKey.tr()} ${context.getLocalizedApiDate(apiDateTimeStamp: coupon.startsAt)} ${LangKeys.toKey.tr()} ${context.getLocalizedApiDate(apiDateTimeStamp: coupon.expiresAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: context.colors.neutral500,
                        ),
                      ),
                      Text(
                        '${LangKeys.discountMinPurchase.tr()} ${formatDouble(coupon.minOrderValue)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.neutral500,
                        ),
                      ),
                      2.hSpace,
                      _CodeChip(code: code, onCopy: onCopy),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 14, start: 4),
                child: Center(
                  child: Assets.media.images.svg.logoVertical.svg(height: 90),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeChip extends StatelessWidget {
  const _CodeChip({required this.code, this.onCopy});

  final String code;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCopy,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: context.colors.primary100,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.media.images.svg.copy.svg(width: 16, height: 16),
            const SizedBox(width: 8),
            Text(
              code,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: context.colors.primaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
