import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';

class ProductReviewCard extends StatelessWidget {
  const ProductReviewCard({
    super.key,
    required this.name,
    required this.rating,
    required this.comment,
  });

  final String name;
  final double rating;
  final String comment;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.style14SemiBold.copyWith(
                    color: colors.black,
                    fontSize: 13,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              AppRateWidget(
                starColor: colors.surface,
                rateColor: colors.greyMutedText,
                rateRatio: '${formatDouble(rating)}',
                size: 12,
                starSize: 16,
                fontWeight: FontWeight.w400,
                spacing: 4,
              ),
            ],
          ),
          Text(
            comment,
            style: AppTextStyles.style13Regular.copyWith(
              color: colors.greyText,
              height: 20 / 13,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
