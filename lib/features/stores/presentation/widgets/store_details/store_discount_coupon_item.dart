import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';

// Ticket geometry from the design: 121 x 158 with a 60-tall coloured head and
// a 32px notch centred on both side edges, 46 above the bottom.
const double _ticketWidth = 121;
const double _ticketHeight = 158;
const double _headHeight = 60;
const double _notchSize = 32;
const double _notchFromBottom = 46;

// Body fills read off the design; the theme carries no equivalent tokens.
const List<Color> _creamBody = [Color(0xffFEFAEA), Color(0xffFEF4D0)];
const List<Color> _greenBody = [Color(0xffF4FAF3), Color(0xffE8F5E7)];

class StoreDiscountCouponItem extends StatelessWidget {
  const StoreDiscountCouponItem({
    super.key,
    required this.coupon,
    required this.storeName,
    this.darkHead = false,
  });

  final CouponModel coupon;
  final String storeName;

  /// The design alternates a dark-green and a yellow head down the list.
  final bool darkHead;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final DateTime? startsAt = DateTime.tryParse(coupon.startsAt ?? '');
    final DateTime? expiresAt = DateTime.tryParse(coupon.expiresAt ?? '');
    final loc.DateFormat dateFormat = loc.DateFormat.yMMMMd(
      context.locale.toString(),
    );
    final String validityText = [
      if (startsAt != null)
        '${LangKeys.fromKey.tr()} ${dateFormat.format(startsAt)}',
      if (expiresAt != null)
        '${LangKeys.toKey.tr()} ${dateFormat.format(expiresAt)}',
    ].join(' ');

    final Color headColor = darkHead
        ? colors.surfaceBright
        : colors.onSecondaryFixedVariant;
    final Color discountColor = darkHead
        ? colors.onSecondaryFixedVariant
        : colors.primaryContainer;
    final Color storeNameColor = darkHead
        ? colors.onPrimary
        : colors.tertiaryContainer;
    final String discountValue = '${coupon.discountValue?.toInt() ?? 0}';

    return InkWell(
      // The design has no code chip, so the whole ticket copies the code.
      onTap: coupon.code == null
          ? null
          : () => Clipboard.setData(ClipboardData(text: coupon.code!)),
      child: Container(
        width: _ticketWidth,
        height: _ticketHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: AppBorderRadius.brCircular16),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: _headHeight,
                  width: double.infinity,
                  alignment: Alignment.center,
                  color: headColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 2,
                    children: [
                      coupon.isPercentage ?? true
                          ? Text(
                              '$discountValue%',
                              textDirection: TextDirection.ltr,
                              style: AppTextStyles.style20SemiBold.copyWith(
                                color: discountColor,
                                height: 1,
                              ),
                            )
                          : NewPriceWidget(
                              color: discountColor,
                              price: discountValue,
                              size: 20,
                            ),
                      Text(
                        '${LangKeys.inStoreKey.tr()} $storeName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.style12SemiBold.copyWith(
                          color: storeNameColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: darkHead ? _creamBody : _greenBody,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          coupon.name ?? LangKeys.discountCouponKey.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.style16Medium.copyWith(
                            color: colors.primaryContainer,
                          ),
                        ),
                        if (validityText.isNotEmpty)
                          Text(
                            validityText,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.style10Medium.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                        Assets.media.images.svg.appLogo.svg(width: 64),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Half-discs painted in the page colour: the ticket clips away the
            // outer half, leaving a notch punched into each side edge.
            Positioned(
              left: -_notchSize / 2,
              top: _notchTop,
              child: _notch(context),
            ),
            Positioned(
              right: -_notchSize / 2,
              top: _notchTop,
              child: _notch(context),
            ),
          ],
        ),
      ),
    );
  }

  static const double _notchTop =
      _ticketHeight - _notchFromBottom - _notchSize / 2;

  Widget _notch(BuildContext context) => Container(
    width: _notchSize,
    height: _notchSize,
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: BoxShape.circle,
    ),
  );
}
