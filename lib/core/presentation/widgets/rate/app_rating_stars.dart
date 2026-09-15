import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class AppRatingStars extends StatelessWidget {
  const AppRatingStars({
    super.key,
    required this.average,
    this.size = 12,
    this.spacing = 2,
    this.color,
    this.emptyColor,
  });

  final double? average;

  final double size;

  final double spacing;

  final Color? color;

  final Color? emptyColor;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color filledColor = color ?? colors.amber500;
    final Color emptyStarColor = emptyColor ?? colors.neutral300;

    final double clamped = (average ?? 0).clamp(0, 5).toDouble();
    final int fullStars = clamped.floor();
    final bool hasHalfStar = clamped > fullStars;

    Widget star(Color color) => Assets.media.images.svg.starIcon.svg(
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing,
      children: List.generate(5, (index) {
        if (index < fullStars) return star(filledColor);
        if (index == fullStars && hasHalfStar) {
          return Stack(
            children: [
              star(emptyStarColor),
              Align(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: 0.5,
                child: star(filledColor),
              ),
            ],
          );
        }
        return star(emptyStarColor);
      }),
    );
  }
}
