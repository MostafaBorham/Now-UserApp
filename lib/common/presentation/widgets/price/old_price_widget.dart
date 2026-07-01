import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../assets/assets.gen.dart';
import '../../../styles/text_styles.dart';
import '../price_cancel_line.dart';

class OldPriceWidget extends StatelessWidget {
  const OldPriceWidget({super.key, required this.color, this.size, required this.price});
  final Color color;
  final String price;
  final double? size;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.ltr,
            spacing: 3,
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
