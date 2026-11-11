import 'package:easy_localization/easy_localization.dart'
    show StringTranslateExtension;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// A pill badge reading "Out of stock", shown in place of the cart control when
/// a product has no stock left. Red background, white text — shared by the
/// product cards and the product-details header.
class OutOfStockLabel extends StatelessWidget {
  const OutOfStockLabel({super.key, this.fontSize, this.wrapText = false});

  /// Overrides the label font size; `null` keeps the base [AppTextStyles] size.
  final double? fontSize;
  final bool wrapText;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final TextStyle style = AppTextStyles.style12Bold.copyWith(
      color: colors.white,
      fontSize: fontSize,
    );
    return Container(
      padding: wrapText
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
          : const EdgeInsets.all(4),
      decoration: ShapeDecoration(
        color: colors.errorContainer,
        shape: wrapText
            ? const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(999)),
              )
            : const _WidthRatioRoundedBorder(radiusRatio: 0.1),
      ),
      child: wrapText
          ? Text(
              LangKeys.outOfStockKey.tr(),
              textAlign: TextAlign.center,
              style: style.copyWith(overflow: TextOverflow.visible),
            )
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                LangKeys.outOfStockKey.tr(),
                maxLines: 1,
                style: style,
              ),
            ),
    );
  }
}

class _WidthRatioRoundedBorder extends OutlinedBorder {
  const _WidthRatioRoundedBorder({required this.radiusRatio, super.side});

  final double radiusRatio;

  RoundedRectangleBorder _resolve(Rect rect) => RoundedRectangleBorder(
    side: side,
    borderRadius: BorderRadius.circular(rect.width * radiusRatio),
  );

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.strokeInset);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _resolve(rect).getInnerPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _resolve(rect).getOuterPath(rect, textDirection: textDirection);

  @override
  bool get preferPaintInterior => true;

  @override
  void paintInterior(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    TextDirection? textDirection,
  }) => _resolve(
    rect,
  ).paintInterior(canvas, rect, paint, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) =>
      _resolve(rect).paint(canvas, rect, textDirection: textDirection);

  @override
  ShapeBorder scale(double t) =>
      _WidthRatioRoundedBorder(radiusRatio: radiusRatio, side: side.scale(t));

  @override
  OutlinedBorder copyWith({BorderSide? side}) => _WidthRatioRoundedBorder(
    radiusRatio: radiusRatio,
    side: side ?? this.side,
  );

  @override
  bool operator ==(Object other) =>
      other is _WidthRatioRoundedBorder &&
      other.radiusRatio == radiusRatio &&
      other.side == side;

  @override
  int get hashCode => Object.hash(radiusRatio, side);
}
