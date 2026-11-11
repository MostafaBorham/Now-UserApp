import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/circular_back_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_reviews/reviews_top_bar/widgets/reviews_filter_button.dart';

class ReviewsTopBar extends StatelessWidget {
  const ReviewsTopBar({super.key, this.onFilterTap});

  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final double buttonSize = MediaQuery.sizeOf(context).width * 0.05;
    final BoxDecoration buttonDecoration = BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: colors.neutral200,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
      boxShadow: [
        BoxShadow(
          color: colors.neutral500.withValues(alpha: 0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
    return Container(
      decoration: BoxDecoration(
        color: colors.white,
        border: Border(bottom: BorderSide(color: colors.neutral200)),
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: kToolbarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: buttonSize * 4 + 16),
                child: Text(
                  LangKeys.reviewsKey.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.style20Bold.copyWith(
                    color: colors.black,
                    fontSize: 22,
                    height: 1.3,
                  ),
                ),
              ),
              Row(
                spacing: 8,
                children: [
                  DecoratedBox(
                    decoration: buttonDecoration,
                    child: CircularBackButton(size: buttonSize),
                  ),
                  const Spacer(),
                  DecoratedBox(
                    decoration: buttonDecoration,
                    child: CircularAppFavouriteIcon(
                      size: buttonSize,
                      elevation: 0,
                      backgroundColor: colors.white,
                      favouriteType: FavouriteType.product,
                    ),
                  ),
                  DecoratedBox(
                    decoration: buttonDecoration,
                    child: ReviewsFilterButton(
                      size: buttonSize,
                      onTap: onFilterTap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
