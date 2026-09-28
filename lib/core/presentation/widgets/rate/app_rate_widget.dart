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
  });
  final Color starColor;
  final Color? rateColor;
  final String rateRatio;
  final String? rateCount;
  final double? size;
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        Assets.media.images.svg.starIcon.svg(
          width: size,
          height: size,
          colorMapper: SvgTint(starColor),
        ),
        Text(
          '$rateRatio ${rateCount != null ? '($rateCount)' : ''}',
          style: TextStyle(
            color: rateColor,
            fontWeight: FontWeight.w600,
            fontSize: size,
          ),
        ),
      ],
    );
  }
}
