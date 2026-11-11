import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/rating_comment_field.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/selectable_rating_stars.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_reviews/write_review_panel/widgets/write_review_rating_row.dart';

class WriteReviewPanel extends StatelessWidget {
  const WriteReviewPanel({
    super.key,
    required this.rating,
    required this.commentController,
    required this.onRatingSelected,
    this.onSubmit,
  });

  final ValueListenable<int> rating;
  final TextEditingController commentController;
  final RatingSelectedCallback onRatingSelected;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final BorderSide border = BorderSide(color: colors.neutral200);
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.paddingOf(context).bottom + 16,
      ),
      decoration: BoxDecoration(
        color: colors.white,
        border: Border(top: border, left: border, right: border),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: rating,
        builder: (BuildContext context, int rating, _) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Text(
              LangKeys.writeReviewKey.tr(),
              style: AppTextStyles.style16Bold.copyWith(
                color: colors.neutral1000,
              ),
            ),
            WriteReviewRatingRow(
              rating: rating,
              onRatingSelected: onRatingSelected,
            ),
            RatingCommentField(
              hint: '${LangKeys.writeYourCommentHereKey.tr()}...',
              controller: commentController,
              enabled: rating >= 1,
            ),
            PrimaryAppButton(
              title: LangKeys.submitRatingKey.tr(),
              titleStyle: AppTextStyles.style16Medium,
              isDisabled: rating < 1,
              onTap: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
