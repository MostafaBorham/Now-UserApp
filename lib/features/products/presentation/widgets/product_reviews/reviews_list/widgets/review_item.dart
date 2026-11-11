import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class ReviewItem extends StatelessWidget {
  const ReviewItem({super.key, required this.name, required this.comment});

  final String name;
  final String comment;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: AppBorderRadius.brCircular12,
        border: Border.all(color: colors.neutral200),
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            name,
            style: AppTextStyles.style14SemiBold.copyWith(
              color: colors.neutral1000,
            ),
          ),
          Text(
            comment,
            style: AppTextStyles.style14Regular.copyWith(
              color: colors.neutral1000,
              height: 22 / 14,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
