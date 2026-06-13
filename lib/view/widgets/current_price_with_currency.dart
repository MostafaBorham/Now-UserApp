import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../assets/assets.gen.dart';
import '../styles/text_styles.dart';

class CurrentPriceWithCurrency extends StatelessWidget {
  const CurrentPriceWithCurrency({
    super.key,
    required this.color, required this.price,
  });

  final Color color;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        AutoSizeText('20',style: AppTextStyles.style14Regular.copyWith(
            color: color
        ),),
        Assets.media.images.svg.realSaudiCurrency.svg(
          width: 8,
          height: 8,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ],
    );
  }
}