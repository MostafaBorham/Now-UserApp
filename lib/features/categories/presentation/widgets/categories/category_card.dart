import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, this.onTap});

  final CategoryModel category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color background = category.primaryColor ?? colors.secondary600;
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
                color: background,
                borderRadius: AppBorderRadius.brCircular10,
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  AppCachedNetworkImage(
                    imageUrl: category.image ?? '',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                    errorBackgroundColor: background,
                  ),
                  // White glow: the image fades to white at its bottom edge so
                  // the card blends into the surface below it, matching the
                  // design (and the home category item's glow). Transparent at
                  // the top so the product stays fully visible.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.6, 1],
                          colors: [
                            colors.white.withValues(alpha: 0),
                            colors.white,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Fixed two-line slot so a wrapping label never shrinks the image;
          // shorter labels just leave the second line empty, keeping every
          // card's image the same height across the grid.
          SizedBox(
            height: 45,
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
