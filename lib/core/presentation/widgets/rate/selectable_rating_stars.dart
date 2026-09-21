import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Reports the star the user tapped, `1`–[SelectableRatingStars.count].
typedef RatingSelectedCallback = void Function(int rating);

/// A tappable row of stars that always fills left-to-right (star `1` is the
/// leftmost, regardless of locale) and paints the first [rating] stars in the
/// filled [color]. The committed value is owned by the parent, which passes it
/// back in through [rating]; the row only reports taps via [onRatingSelected].
class SelectableRatingStars extends StatelessWidget {
  const SelectableRatingStars({
    super.key,
    required this.rating,
    this.onRatingSelected,
    this.count = 5,
    this.size = 20,
    this.spacing = 4,
    this.color,
    this.emptyColor,
  });

  /// How many stars are currently filled (`0`–[count]).
  final int rating;

  /// Fires the tapped star value; a null callback renders a read-only row.
  final RatingSelectedCallback? onRatingSelected;

  /// Total number of stars in the row.
  final int count;

  /// Width/height of a single star icon.
  final double size;

  /// Gap between the stars.
  final double spacing;

  /// Colour of a filled star. Defaults to the amber rating colour.
  final Color? color;

  /// Colour of an empty star. Defaults to a neutral grey.
  final Color? emptyColor;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color filledColor = color ?? colors.amber500;
    final Color emptyStarColor = emptyColor ?? colors.neutral300;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: spacing,
        children: List<Widget>.generate(count, (int index) {
          final bool isFilled = index < rating;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onRatingSelected == null
                ? null
                : () => onRatingSelected!(index + 1),
            child: Assets.media.images.svg.orderStarRate.svg(
              width: size,
              height: size,
              colorFilter: ColorFilter.mode(
                isFilled ? filledColor : emptyStarColor,
                BlendMode.srcIn,
              ),
            ),
          );
        }),
      ),
    );
  }
}
