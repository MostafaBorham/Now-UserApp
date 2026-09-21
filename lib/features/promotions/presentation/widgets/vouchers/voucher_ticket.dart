// Aliased so easy_localization's re-exported intl TextDirection doesn't shadow
// Flutter's; the `.tr()` extension stays in scope regardless of the prefix.
import 'package:easy_localization/easy_localization.dart' as _;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/overlay_opacity_widget.dart';
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

/// The shared voucher/coupon ticket used across the app (store details and
/// checkout). It is purely presentational and model-agnostic — callers pass the
/// already-resolved display strings and own whatever [onTap] should do (select,
/// unselect, apply, copy…). This is the single source of the ticket design;
/// only the surrounding action differs between call sites.
///
/// Ticket geometry: 121 x 158 with a coloured head (alternating dark-green and
/// yellow down a row via [darkHead]) and two side notches at the colour seam.
class VoucherTicket extends StatelessWidget {
  const VoucherTicket({
    super.key,
    required this.discountValue,
    this.name,
    this.validityText = '',
    this.isPercentage = true,
    this.darkHead = false,
    this.isSelected = false,
    this.isDimmed = false,
    this.onTap,
  });

  /// The discount amount as a display string, without any unit (e.g. `'20'`).
  /// Rendered as `'20%'` when [isPercentage], else as a price via
  /// [NewPriceWidget].
  final String discountValue;

  /// Whether [discountValue] is a percentage (vs a fixed amount).
  final bool isPercentage;

  /// The voucher/coupon name, shown in the head under the discount value.
  final String? name;

  /// The validity window line (e.g. "From … To …"). Hidden when empty.
  final String validityText;

  /// The design alternates a dark-green and a yellow head down the list.
  final bool darkHead;

  /// When selected the ticket keeps its shape but fades to a light opacity.
  final bool isSelected;

  /// Dims the ticket and blocks taps (e.g. a voucher not applicable here).
  final bool isDimmed;

  /// Tap handler. When null the ticket is not tappable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    final Color headColor = darkHead
        ? colors.surfaceBright
        : colors.onSecondaryFixedVariant;
    final Color discountColor = darkHead
        ? colors.onSecondaryFixedVariant
        : colors.primaryContainer;
    final Color nameColor = darkHead
        ? colors.white
        : colors.tertiaryContainer;
    final String? couponName = name?.isNotEmpty ?? false ? name : null;

    return OverlayOpacityWidget(
      disabled: isDimmed,
      child: InkWell(
        onTap: onTap,
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
                      // The ticket is a fixed 121 wide and the discount line is
                      // fixed-size, so it had no give at all: a two-decimal
                      // fixed amount, or any three-digit value, overflowed the
                      // head outright. Scaling down is what the app already
                      // does in the same situation (see StoreInfoRow).
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: isPercentage
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
                      ),
                      if (couponName != null)
                        Text(
                          couponName,
                          textAlign: TextAlign.center,
                          // AppTextStyles bake in ellipsis; override so the full
                          // text wraps instead of being truncated.
                          overflow: TextOverflow.visible,
                          style: AppTextStyles.style12SemiBold.copyWith(
                            color: nameColor,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  // The notches are painted inside the body so they centre on
                  // the body's height, not the whole ticket's.
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
                        // Name pinned to the top, logo at the bottom. The
                        // validity is centred in the free space between them,
                        // with a fixed 8px gap kept above the logo.
                        child: Column(
                          children: [
                            Text(
                              LangKeys.purchaseVoucherKey.tr(),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                              // Tight line height so the box hugs the glyphs;
                              // the default leading would pad the label's bottom.
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
