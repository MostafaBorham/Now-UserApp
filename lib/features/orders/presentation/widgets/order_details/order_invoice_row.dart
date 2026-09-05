import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';

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
        NewPriceWidget(
          color: valueColor,
          size: 15,
          fontWeight: FontWeight.w700,
          price: value.toStringAsFixed(2),
        ),
      ],
    );
  }
}
