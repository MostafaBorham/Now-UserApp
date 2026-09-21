import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/selectable_rating_stars.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/order_rating/rating_comment_field.dart';

/// One product's rating block inside the products card: its thumbnail and name
/// alongside a tappable star row, with a comment box underneath. The committed
/// [rating] and the comment [controller] are owned by the screen; the row
/// reports taps through [onRatingSelected].
class OrderRatingProductRow extends StatelessWidget {
  const OrderRatingProductRow({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.commentHint,
    this.onRatingSelected,
    this.commentController,
    this.readOnly = false,
  });

  final String name;
  final String imageUrl;
  final int rating;
  final String commentHint;
  final RatingSelectedCallback? onRatingSelected;
  final TextEditingController? commentController;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: AppBorderRadius.brCircular10,
                border: Border.all(
                  color: colors.neutral200.withValues(alpha: 0.5),
                ),
              ),
              child: AppCachedNetworkImage(
                imageUrl: imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Text(
                name,
                overflow: TextOverflow.visible,
                style: AppTextStyles.style14SemiBold.copyWith(
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
            fillColor: colors.white,
            readOnly: readOnly,
          ),
      ],
    );
  }
}
