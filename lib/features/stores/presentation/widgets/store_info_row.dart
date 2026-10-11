import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/svg_tint.dart';

class StoreInfoRow extends StatelessWidget {
  const StoreInfoRow({
    super.key,
    required this.infoFontSize,
    required this.infoIconSize,
    this.deliveryTime,
    this.distance,
    this.deliveryFee,
    this.color,
  });
  final double infoFontSize;
  final double infoIconSize;
  final String? deliveryTime;
  final String? distance;
  final String? deliveryFee;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color iconColor = color ?? colors.neutral500;
    final Color textColor = color ?? colors.black;
    // Every child is fixed-size, so the row had no give at all: a long delivery
    // time, a three-digit distance or a wider fee overflowed it outright.
    // Scaling down is what the app's buttons already do in the same situation.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Assets.media.images.svg.timeIcon.svg(
            width: infoIconSize,
            colorMapper: SvgTint(iconColor),
          ),
          Text(
            deliveryTime ?? '-',
            style: AppTextStyles.style12Medium.copyWith(
              color: textColor,
              fontSize: infoFontSize,
            ),
          ),
          5.wSpace,
          // No distance (no location to measure from) leaves the pair out:
          // it used to read "0 km" or "-" (BUG-004).
          if (distance != null) ...[
            Assets.media.images.svg.locationIcon.svg(
              width: infoIconSize,
              colorMapper: SvgTint(iconColor),
            ),
            Text(
              distance!,
              style: AppTextStyles.style12Medium.copyWith(
                color: textColor,
                fontSize: infoFontSize,
              ),
            ),
            5.wSpace,
          ],
          ReverseWidget(
            child: Assets.media.images.svg.shippingIcon.svg(
              width: infoIconSize,
              colorMapper: SvgTint(iconColor),
            ),
          ),
          NewPriceWidget(
            color: textColor,
            // Callers pass an already-formatted amount; the fallback keeps the
            // same two-decimal shape so a missing fee doesn't read as a
            // differently-precise price.
            price: deliveryFee ?? formatMoney(null),
            size: infoFontSize,
          ),
        ],
      ),
    );
  }
}
