import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/selectable_rating_stars.dart';

class WriteReviewRatingRow extends StatelessWidget {
  const WriteReviewRatingRow({
    super.key,
    required this.rating,
    required this.onRatingSelected,
  });

  final int rating;
  final RatingSelectedCallback onRatingSelected;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 12,
      children: [
        Flexible(
          child: Text(
            LangKeys.theRatingKey.tr(),
            style: AppTextStyles.style14SemiBold.copyWith(
              color: colors.neutral1000,
            ),
          ),
        ),
        SelectableRatingStars(
          rating: rating,
          onRatingSelected: onRatingSelected,
          color: colors.surface,
          emptyColor: colors.neutral200,
        ),
      ],
    );
  }
}
