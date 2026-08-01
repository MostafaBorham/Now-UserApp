import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class OldPriceWidget extends StatelessWidget {
  const OldPriceWidget({super.key, required this.color, this.size, required this.price});
  final Color color;
  final String price;
  final double? size;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.ltr,
            spacing: 2,
            children: [
              Assets.media.images.svg.realSaudiCurrency.svg(
                width: size ?? 14,
                height: size ?? 14,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              AutoSizeText(
                price,
                style: AppTextStyles.style14Medium.copyWith(
                  color: color,
                  height: 1,
                  fontSize: size,
                ),
              ),
            ],
          ),
        ),

        Positioned.fill(
          child: Center(
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                height: 2,
                color: colors.inversePrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
