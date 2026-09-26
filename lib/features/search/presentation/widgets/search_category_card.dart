import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class SearchCategoryCard extends StatelessWidget {
  const SearchCategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  final CategoryModel category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context, cardConstraints) {
        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            clipBehavior: Clip.antiAlias,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: colors.white,
              borderRadius: AppBorderRadius.brCircular12,
              boxShadow: [
                BoxShadow(
                  color: colors.black.withValues(alpha: 0.25),
                  blurRadius: 1.35,
                  spreadRadius: 0,
                  offset: Offset(0, 0),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 6,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: colors.secondary600,
                      borderRadius: AppBorderRadius.brCircular12,
                    ),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        AppCachedNetworkImage(
                          imageUrl: category.image ?? '',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                          errorBackgroundColor: colors.secondary600,
                        ),
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
                Text(
                  context.getLocalizedApiText(category.name),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.style14SemiBold.copyWith(
                    color: colors.neutral1200,
                    height: 1,
                    fontSize: cardConstraints.maxWidth * 0.12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
