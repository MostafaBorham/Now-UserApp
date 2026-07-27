import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
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
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: AppBorderRadius.brCircular12,
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  AppCachedNetworkImage(
                    imageUrl: category.image??'',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  if (category.descendantsCount! < 0)
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: AppBorderRadius.brCircular7,
                      ),
                      child: Text(
                        '${category.descendantsCount} % ${LangKeys.discountKey.tr()}',
                        maxLines: 1,
                        style: AppTextStyles.style18SemiBold.copyWith(
                          color: colors.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Text(
            context.getLocalizedApiText(category.name),
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
