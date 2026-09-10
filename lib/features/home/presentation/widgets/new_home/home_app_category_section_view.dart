import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_view_all_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

/// A `products_by_category` section in its `color_only` design: the category
/// name over a wave washed in the section's own [primaryColor], and a row of
/// that category's products.
class HomeAppCategorySectionView extends StatelessWidget {
  const HomeAppCategorySectionView({
    super.key,
    required this.categoryModel,
    required this.productModels,
    this.primaryColor,
    this.textColor,
    this.showViewAll = true,
  });

  final CategoryModel categoryModel;
  final List<ProductModel> productModels;

  /// Section theming from the feed; each falls back to a theme colour when the
  /// admin left it unset.
  final Color? primaryColor;
  final Color? textColor;
  final bool showViewAll;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color accent = primaryColor ?? colors.onInverseSurface;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double productRowHeight = constraints.maxWidth * 0.78;
        return Stack(
          children: [
            Positioned.fill(
              child: ReverseWidget(
                applyReverse: !context.isRTL,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (Rect bounds) => LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    stops: [0, 0.5],
                    colors: [
                      accent.withValues(alpha: 0.2),
                      accent.withValues(alpha: 0.02),
                    ],
                  ).createShader(bounds),
                  child: Assets.media.images.svg.oneWaveBackground.svg(
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 20,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          context.getLocalizedApiText(categoryModel.name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor ?? colors.black,
                          ),
                        ),
                      ),
                      // ponytail: the chip is inert — the feed sends the
                      // category's id and name but no slug, and category
                      // details fetches by slug. Wire the tap once the payload
                      // carries `category_slug`.
                      if (showViewAll)
                        HomeViewAllWidget(
                          size: 15,
                          startBackgroundColor: accent.withValues(alpha: 0.5),
                          endBackgroundColor: accent.withValues(alpha: 0.2),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: productRowHeight,
                  child: ListView.separated(
                    padding: EdgeInsetsDirectional.only(
                      start: 16
                    ),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return ProductItem3View(product: productModels[index]);
                    },
                    separatorBuilder: (context, index) => 4.wSpace,
                    itemCount: productModels.length,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}