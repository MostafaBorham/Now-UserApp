import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/copy_to_clipboard.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';

// Ticket geometry from the design: 121 x 158 with a 60-tall coloured head and
// a 32px notch centred (vertically) on both side edges.
const double _ticketWidth = 121;
const double _ticketHeight = 158;
const double _headHeight = 60;
const double _notchSize = 32;

// Horizontal body padding, and how far the notches punch past it into the body.
// The validity text sits level with the notches, so it must clear this overlap
// to avoid being covered — it wraps (up to 2 lines) instead.
const double _bodyHPadding = 8;
const double _notchOverlap = _notchSize / 2 - _bodyHPadding;

// Body fills read off the design; the theme carries no equivalent tokens.
const List<Color> _creamBody = [Color(0xffFEFAEA), Color(0xffFEF4D0)];
const List<Color> _greenBody = [Color(0xffF4FAF3), Color(0xffE8F5E7)];

// The design marks the selected ticket by fading the whole thing (opacity 15%).
const double _selectedOpacity = 0.15;

class StoreDiscountCouponItem extends StatelessWidget {
  const StoreDiscountCouponItem({
    super.key,
    required this.coupon,
    required this.storeName,
    this.darkHead = false,
    this.isSelected = false,
    this.onTap,
  });

  final CouponModel coupon;
  final String storeName;

  /// The design alternates a dark-green and a yellow head down the list.
  final bool darkHead;

  /// When selected the ticket keeps its shape but fades to a light opacity.
  final bool isSelected;

  /// Tap handler. When null the whole ticket copies the coupon code instead.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

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
        ? colors.white
        : colors.tertiaryContainer;
    final String discountValue = '${coupon.discountValue?.toInt() ?? 0}';

    return InkWell(
      // The design has no code chip, so the whole ticket copies the code
      // unless a tap handler (e.g. selection) is supplied by the parent.
      onTap:
          onTap ??
          (coupon.code == null
              ? null
              : () => CopyToClipboard.copy(context, coupon.code!)),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isSelected ? _selectedOpacity : 1,
        child: Container(
          width: _ticketWidth,
          // No fixed height: the ticket grows to fit its (un-truncated) text.
          // [_ticketHeight] is only the floor, and the list equalises every
          // ticket to the tallest one so the row still reads as one height.
          constraints: const BoxConstraints(minHeight: _ticketHeight),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: AppBorderRadius.brCircular16),
          child: Column(
            children: [
              Container(
                constraints: const BoxConstraints(minHeight: _headHeight),
                width: double.infinity,
                color: headColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      textAlign: TextAlign.center,
                      // AppTextStyles bake in ellipsis; override so the full
                      // text wraps instead of being truncated.
                      overflow: TextOverflow.visible,
                      style: AppTextStyles.style12SemiBold.copyWith(
                        color: storeNameColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                // The notches are painted inside the body so they centre on the
                // body's height, not the whole ticket's.
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        left: _bodyHPadding,
                        right: _bodyHPadding,
                        top: 10,
                        bottom: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: darkHead ? _creamBody : _greenBody,
                        ),
                      ),
                      // Name pinned to the top, logo at the bottom. The validity
                      // is centred in the free space between them, with a fixed
                      // 8px gap kept above the logo.
                      child: Column(
                        children: [
                          Text(
                            coupon.name ?? LangKeys.discountCouponKey.tr(),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.visible,
                            // Tight line height so the box hugs the glyphs; the
                            // default leading would pad the name's bottom.
                            style: AppTextStyles.style16Medium.copyWith(
                              color: colors.primaryContainer,
                              height: 1,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: validityText.isEmpty
                                  ? const SizedBox.shrink()
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: _notchOverlap,
                                      ),
                                      child: Text(
                                        validityText,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.visible,
                                        style: AppTextStyles.style10Medium
                                            .copyWith(
                                              color: colors.neutral500,
                                              height: 1,
                                            ),
                                      ),
                                    ),
                            ),
                          ),
                          if (validityText.isNotEmpty)
                            const SizedBox(height: 8),
                          Assets.media.images.svg.appLogo.svg(width: 64),
                        ],
                      ),
                    ),
                    // Half-discs painted in the page colour: the ticket clips
                    // away the outer half, leaving a notch punched into each
                    // side edge, centred on the body's height.
                    Positioned(
                      left: -_notchSize / 2,
                      top: 0,
                      bottom: 0,
                      child: Center(child: _notch(context)),
                    ),
                    Positioned(
                      right: -_notchSize / 2,
                      top: 0,
                      bottom: 0,
                      child: Center(child: _notch(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notch(BuildContext context) => Container(
    width: _notchSize,
    height: _notchSize,
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: BoxShape.circle,
    ),
  );
}
