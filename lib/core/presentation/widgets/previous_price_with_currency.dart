import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'price_cancel_line.dart';

class PreviousPriceWithCurrency extends StatelessWidget {
  const PreviousPriceWithCurrency({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return PriceCancelLine(
      child: Row(
        spacing: 5,
        children: [
          Assets.media.images.svg.realSaudiCurrency.svg(
            width: 14,
            height: 14,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(colors.inversePrimary, BlendMode.srcIn),
          ),
          AutoSizeText('10',style: AppTextStyles.style14Medium.copyWith(
              color: colors.inversePrimary,
            height: 1
          ),),

        ],
      ),
    );
  }
}
