import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_reviews/reviews_rating_summary/widgets/overall_rating.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_reviews/reviews_rating_summary/widgets/rating_distribution/rating_distribution.dart';

class ReviewsRatingSummary extends StatelessWidget {
  const ReviewsRatingSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: AppBorderRadius.brCircular16,
        border: Border.all(color: colors.primary500Main),
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          spacing: 20,
          children: [
            const Expanded(child: OverallRating()),
            VerticalDivider(width: 1, thickness: 1, color: colors.primary200),
            const Expanded(child: RatingDistribution()),
          ],
        ),
      ),
    );
  }
}
