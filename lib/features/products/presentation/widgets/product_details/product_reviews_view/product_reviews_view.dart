import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_reviews_view/widgets/product_review_card.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_reviews_view/widgets/product_reviews_view_all_button.dart';

class ProductReviewsView extends StatelessWidget {
  const ProductReviewsView({super.key, this.onViewAllTap});

  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        Text(
          LangKeys.reviewsKey.tr(),
          style: AppTextStyles.style16Bold.copyWith(
            color: context.colors.black,
            height: 1.5,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: List.generate(
                2,
                (index) => const ProductReviewCard(
                  name: 'Ahmed Ali',
                  rating: 4.0,
                  comment:
                      'Excellent product, great performance and beautiful design. I highly recommend it.',
                ),
              ),
            ),
            ProductReviewsViewAllButton(onTap: onViewAllTap),
          ],
        ),
      ],
    );
  }
}
