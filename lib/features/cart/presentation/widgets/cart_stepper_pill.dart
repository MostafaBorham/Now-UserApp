import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// The product card's cart control, to Figma (User-App 516:12374 →
/// 584:13259 / 584:13390, BUG-010/013/019).
///
/// Collapsed: a 28 dp green circle with a square bottom-start corner and a
/// white "+" (or the quantity already in the cart). [expanded] grows it, toward
/// the start, into an 86 × 28 pill — add, the count, then trash at one unit or
/// minus from two up — while the "+" fades out and the square corner rounds
/// into the pill's.
///
/// The visuals keep Figma's size; the control's box reaches [reach] further on
/// its top and start sides — the sides facing into the card — so each tap
/// target is about 40 dp tall without moving the pill off the card's corner.
class CartStepperPill extends StatelessWidget {
  const CartStepperPill({
    super.key,
    required this.expanded,
    required this.counter,
    this.isLoading = false,
    this.canIncrement = true,
    this.onTap,
    this.onInc,
    this.onDec,
    this.onDelete,
    this.onAnimationEnd,
  });

  final bool expanded;
  final int counter;

  /// A request is in flight: the count becomes a spinner and the icons stop
  /// responding.
  final bool isLoading;

  final bool canIncrement;

  /// The collapsed button's tap.
  final VoidCallback? onTap;

  final VoidCallback? onInc;
  final VoidCallback? onDec;

  /// The trash icon, shown in place of minus while a single unit is left.
  final VoidCallback? onDelete;

  /// Fires when an expand or collapse animation settles.
  final VoidCallback? onAnimationEnd;

  static const double height = 28;
  static const double _collapsedWidth = 28;
  static const double _expandedWidth = 86;
  static const double reach = 12;
  static const Duration _duration = Duration(milliseconds: 300);

  static const BorderRadiusDirectional _bubble = BorderRadiusDirectional.only(
    topStart: Radius.circular(14),
    topEnd: Radius.circular(14),
    bottomEnd: Radius.circular(14),
  );
  static const BorderRadiusDirectional _pill = BorderRadiusDirectional.all(
    Radius.circular(8),
  );

  // Swallows a tap on a dead part of the pill: the card underneath opens the
  // product, which would navigate away mid-edit.
  static void _swallow() {}

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final TextStyle countStyle = AppTextStyles.style16SemiBold.copyWith(
      color: colors.white,
      height: 1,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: expanded ? 1 : 0),
      duration: _duration,
      curve: Curves.easeInOut,
      onEnd: onAnimationEnd,
      builder: (BuildContext context, double t, Widget? _) {
        final double width = lerpDouble(_collapsedWidth, _expandedWidth, t)!;
        final BorderRadiusGeometry radius = BorderRadiusDirectional.lerp(
          _bubble,
          _pill,
          t,
        )!;

        return SizedBox(
          width: width + reach,
          height: height + reach,
          child: Stack(
            children: <Widget>[
              PositionedDirectional(
                end: 0,
                bottom: 0,
                width: width,
                height: height,
                child: ClipRRect(
                  borderRadius: radius,
                  child: ColoredBox(
                    color: colors.primary500Main,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        if (t < 1)
                          Opacity(
                            opacity: 1 - t,
                            child: counter < 1
                                ? Assets.media.images.svg.cardCartAdd.svg(
                                    width: 20,
                                    height: 20,
                                  )
                                : Text('$counter', style: countStyle),
                          ),
                        if (t > 0)
                          Opacity(
                            opacity: t,
                            // Laid out at full width and revealed as the pill
                            // grows from its end.
                            child: OverflowBox(
                              alignment: AlignmentDirectional.centerEnd,
                              minWidth: _expandedWidth,
                              maxWidth: _expandedWidth,
                              child: _expandedRow(colors, countStyle),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(child: _tapTargets()),
            ],
          ),
        );
      },
    );
  }

  Widget _expandedRow(AppColorScheme colors, TextStyle countStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Opacity(
            opacity: canIncrement ? 1 : 0.4,
            child: Assets.media.images.svg.cardCartAddBulk.svg(
              width: 20,
              height: 20,
            ),
          ),
          SizedBox(
            width: 24,
            child: Center(
              child: isLoading
                  ? SizedBox.square(
                      dimension: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.white,
                      ),
                    )
                  : Text(
                      '$counter',
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      style: countStyle,
                    ),
            ),
          ),
          counter < 2
              ? Assets.media.images.svg.cardCartTrashBulk.svg(
                  width: 20,
                  height: 20,
                )
              : Assets.media.images.svg.cardCartMinusBulk.svg(
                  width: 20,
                  height: 20,
                ),
        ],
      ),
    );
  }

  /// Invisible targets over the whole box, [reach] included: one for the
  /// collapsed button, three — add, the count, remove — for the pill.
  Widget _tapTargets() {
    Widget target(VoidCallback? onTap) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isLoading ? _swallow : (onTap ?? _swallow),
    );

    if (!expanded) return target(onTap);
    return Row(
      children: <Widget>[
        Expanded(child: target(canIncrement ? onInc : null)),
        Expanded(child: target(null)),
        Expanded(child: target(counter < 2 ? onDelete : onDec)),
      ],
    );
  }
}
