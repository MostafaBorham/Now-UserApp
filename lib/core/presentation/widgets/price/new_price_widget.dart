import 'package:flutter/material.dart';

import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/svg_tint.dart';

class NewPriceWidget extends StatelessWidget {
  const NewPriceWidget({
    super.key,
    required this.color,
    this.size = 20,
    required this.price,
    this.fontWeight,
    this.ellipsis = false,
    this.symbolSize,
  });
  final Color color;
  final String price;
  final double? size;
  final FontWeight? fontWeight;
  final bool ellipsis;
  final double? symbolSize;
  @override
  Widget build(BuildContext context) {
    final Widget priceText = Text(
      price,
      maxLines: ellipsis ? 1 : null,
      overflow: ellipsis ? TextOverflow.ellipsis : null,
      style: AppTextStyles.style28SemiBold.copyWith(
        color: color,
        fontSize: size! * 0.9,
        height: 1,
        fontWeight: fontWeight,
      ),
    );
    return Row(
      textDirection: TextDirection.ltr,
      spacing: 3,
      mainAxisSize: .min,
      children: [
        Assets.media.images.svg.realSaudiCurrency.svg(
          width: symbolSize ?? size,
          height: symbolSize ?? size,
          fit: BoxFit.contain,
          colorMapper: SvgTint(color),
        ),
        ellipsis ? Flexible(child: priceText) : priceText,
      ],
    );
  }
}
