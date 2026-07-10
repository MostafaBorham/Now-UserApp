import 'package:flutter/material.dart';

import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class NewPriceWidget extends StatelessWidget {
  const NewPriceWidget({super.key, required this.color, this.size = 20, required this.price});
  final Color color;
  final String price;
  final double? size;
  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      spacing: 5,
      mainAxisSize: .min,
      children: [
        Assets.media.images.svg.realSaudiCurrency.svg(
          width: size,
          height: size,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        Text(price,style: AppTextStyles.style28SemiBold.copyWith(
          color: color,
          fontSize: size!*0.9,
          height: 1,
        ),),

      ],
    );
  }
}
