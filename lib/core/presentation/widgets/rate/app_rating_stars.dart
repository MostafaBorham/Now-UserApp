import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// A read-only 5-star row that reflects a rating [average] with half-star
/// precision.
///
/// The filled-star count follows the rating's whole part, plus one half star
/// whenever there is any fractional remainder: `1.0` → 1 star, anything above
/// `1` and below `2` → 1.5 stars, `2.0` → 2 stars, and so on up to 5. An
/// [average] above `5` (or `null`) is clamped into the `0`–`5` range, so it
/// never shows more than five stars.
class AppRatingStars extends StatelessWidget {
  const AppRatingStars({
    super.key,
    required this.average,
    this.size = 12,
    this.spacing = 2,
    this.color,
    this.emptyColor,
  });

  /// The rating average the stars represent.
  final double? average;

  /// Width/height of a single star icon.
  final double size;

  /// Gap between the stars.
  final double spacing;

  /// Colour of the filled portion. Defaults to the amber rating colour.
  final Color? color;

  /// Colour of the empty portion. Defaults to a neutral grey.
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
          // Empty star with its leading half overlaid by a filled one.
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
