import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_reviews/reviews_rating_summary/widgets/rating_distribution/widgets/rating_distribution_row.dart';

class RatingDistribution extends StatelessWidget {
  const RatingDistribution({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        Text(
          LangKeys.ratingsKey.tr(),
          style: AppTextStyles.style14SemiBold.copyWith(
            color: context.colors.neutral1000,
          ),
        ),
        ...List.generate(
          5,
          (index) => RatingDistributionRow(
            stars: 5 - index,
            count: 960,
            progress: 0.75,
          ),
        ),
      ],
    );
  }
}
