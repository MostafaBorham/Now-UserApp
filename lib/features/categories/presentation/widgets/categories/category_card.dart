import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
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
    final AppColorScheme colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 6,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: AppBorderRadius.brCircular10,
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




                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.6, 1],
                          colors: [colors.white.withValues(alpha: 0), colors.white],
                        ),
                      ),
                    ),
                  ),




                  if (hasOffer)
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
                          color: colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),



          SizedBox(
            height: 36,
            child: Text(
              context.getLocalizedApiText(category.name),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.style14SemiBold.copyWith(
                color: colors.neutral1200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
