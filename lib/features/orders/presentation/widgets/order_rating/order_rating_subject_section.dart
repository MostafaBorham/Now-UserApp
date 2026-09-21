import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/selectable_rating_stars.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/order_rating/rating_comment_field.dart';

/// A single rateable subject that isn't a product — the courier or the store.
/// Shows the [title] beside a tappable star row, then a grey comment box. The
/// committed [rating] and comment [controller] live on the screen.
class OrderRatingSubjectSection extends StatelessWidget {
  const OrderRatingSubjectSection({
    super.key,
    required this.title,
    required this.rating,
    required this.commentHint,
    this.onRatingSelected,
    this.commentController,
    this.readOnly = false,
  });

  final String title;
  final int rating;
  final String commentHint;
  final RatingSelectedCallback? onRatingSelected;
  final TextEditingController? commentController;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.style14Medium.copyWith(
                  color: colors.black,
                ),
              ),
            ),
            SelectableRatingStars(
              rating: rating,
              onRatingSelected: onRatingSelected,
            ),
          ],
        ),
        if (!readOnly || (commentController?.text.isNotEmpty ?? false))
          RatingCommentField(
            hint: commentHint,
            controller: commentController,
            fillColor: colors.onPrimaryContainer,
            readOnly: readOnly,
          ),
      ],
    );
  }
}
