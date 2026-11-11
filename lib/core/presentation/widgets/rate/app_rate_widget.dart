import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/svg_tint.dart';

class AppRateWidget extends StatelessWidget {
  const AppRateWidget({
    super.key,
    required this.starColor,
    this.rateColor,
    required this.rateRatio,
    this.rateCount,
    this.size = 10,
    this.starSize,
    this.fontWeight = FontWeight.w600,
    this.spacing = 5,
  });
  final Color starColor;
  final Color? rateColor;
  final String rateRatio;
  final String? rateCount;
  final double? size;
  final double? starSize;
  final FontWeight fontWeight;
  final double spacing;
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: spacing,
      children: [
        Assets.media.images.svg.starIcon.svg(
          width: starSize ?? size,
          height: starSize ?? size,
          colorMapper: SvgTint(starColor),
        ),
        Text(
          '$rateRatio ${rateCount != null ? '($rateCount)' : ''}',
          style: TextStyle(
            color: rateColor,
            fontWeight: fontWeight,
            fontSize: size,
          ),
        ),
      ],
    );
  }
}
