import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// One label ↔ money row of the order invoice summary: a left-aligned [label]
/// and a right-aligned currency icon + [value]. Every row shares this geometry
/// so subtotal, VAT, fees, discount and total stay aligned; [isTotal] switches
/// the label to the heavier total weight and [valueColor] tints the amount
/// (e.g. discount in error red, total in primary).
class OrderInvoiceRow extends StatelessWidget {
  const OrderInvoiceRow({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    this.isTotal = false,
  });

  final String label;
  final double value;
  final Color valueColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style:
                (isTotal
                        ? AppTextStyles.style14SemiBold
                        : AppTextStyles.style14Regular)
                    .copyWith(color: colors.black),
          ),
        ),
        Row(
          spacing: 5,
          children: [
            Assets.media.images.svg.realSaudiCurrency.svg(
              width: 15,
              height: 15,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(valueColor, BlendMode.srcIn),
            ),
            AutoSizeText(
              value.toStringAsFixed(2),
              style: AppTextStyles.style14Bold.copyWith(color: valueColor),
            ),
          ],
        ),
      ],
    );
  }
}
