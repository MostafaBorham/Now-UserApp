import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    this.hasOffer = false,
    this.onTap,
  });

  final CategoryModel category;
  final bool hasOffer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Material(
              borderRadius: AppBorderRadius.brCircular18,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 2,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  CachedNetworkImage(
                    imageUrl: category.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const SizedBox.shrink(),
                    errorWidget: (_, _, _) => const SizedBox.shrink(),
                  ),
                  if(category.discountPercentage!=null) _DiscountBadge(percentage: category.discountPercentage!)
                ],
              ),
            ),
          ),
          Text(
            category.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.style14Medium.copyWith(
              color: colors.onTertiaryFixed,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percentage});

  final int percentage;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: AppBorderRadius.brCircular7,
      ),
      child: Text(
        '$percentage % ${LangKeys.discountKey.tr()}',
        style: AppTextStyles.style18SemiBold.copyWith(
          color: colors.onPrimary,
        ),
      ),
    );
  }
}
