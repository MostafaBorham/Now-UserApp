import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class RatingDistributionRow extends StatelessWidget {
  const RatingDistributionRow({
    super.key,
    required this.stars,
    required this.count,
    required this.progress,
  });

  final int stars;
  final int count;
  final double progress;

  static final BorderRadius _barRadius = BorderRadius.circular(3);

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 8,
      children: [
        Text(
          LangKeys.starsCountKey.plural(stars),
          style: AppTextStyles.style14SemiBold.copyWith(
            color: colors.neutral1000,
          ),
        ),
        Flexible(
          child: Container(
            height: 6,
            constraints: const BoxConstraints(maxWidth: 68),
            alignment: AlignmentDirectional.centerStart,
            decoration: BoxDecoration(
              color: colors.neutral200,
              borderRadius: _barRadius,
            ),
            child: FractionallySizedBox(
              widthFactor: progress,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.ratingBar,
                  borderRadius: _barRadius,
                ),
              ),
            ),
          ),
        ),
        Text(
          '$count',
          style: AppTextStyles.style14Regular.copyWith(
            color: colors.neutral500,
          ),
        ),
      ],
    );
  }
}
