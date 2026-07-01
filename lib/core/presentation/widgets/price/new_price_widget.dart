import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class NewPriceWidget extends StatelessWidget {
  const NewPriceWidget({super.key, required this.color, this.size, required this.price});
  final Color color;
  final String price;
  final double? size;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Row(
      textDirection: TextDirection.ltr,
      spacing: 5,
      mainAxisSize: .min,
      children: [
        Assets.media.images.svg.realSaudiCurrency.svg(
          width: size?? 20,
          height: size?? 20,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        AutoSizeText(price,style: AppTextStyles.style28SemiBold.copyWith(
          color: color,
          fontSize: size,
          height: 1,
        ),),

      ],
    );
  }
}
