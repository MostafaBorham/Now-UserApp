import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/formatters/arabic_kashida_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_view_all_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

/// A `products_by_category` section in its `color_with_image` design: the
/// category name with the section's own artwork beside it, over a wave washed
/// in [primaryColor], and a row of that category's products.
class HomeAppCategoryWithLogoSectionView extends StatelessWidget {
  const HomeAppCategoryWithLogoSectionView({
    super.key,
    required this.categoryModel,
    required this.productModels,
    this.imageUrl,
    this.primaryColor,
    this.textColor,
    this.showViewAll = true,
  });

  final CategoryModel categoryModel;
  final List<ProductModel> productModels;

  /// The section's header artwork, already resolved to the current locale.
  /// Empty or null renders the header as title-only.
  final String? imageUrl;

  /// Section theming from the feed; each falls back to a theme colour when the
  /// admin left it unset.
  final Color? primaryColor;
  final Color? textColor;
  final bool showViewAll;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color accent = primaryColor ?? colors.error;
    final String image = imageUrl ?? '';
    return LayoutBuilder(
      builder: (context, con) {
        return Stack(
          children: [
            Positioned.fill(
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (Rect bounds) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.8],
                  colors: [accent.withValues(alpha: 0.7), colors.white],
                ).createShader(bounds),
                child: ReverseWidget(
                  applyReverse: !context.isRTL,
                  child: Padding(
                    padding: EdgeInsets.only(top: con.maxWidth * 0.035),
                    child: Assets.media.images.svg.twoWaveBackground.svg(
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              spacing: 5,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 8,
                    children: [
                      Flexible(
                        child: Text(
                          formatArabicKashida(
                            context.getLocalizedApiText(categoryModel.name),
                            count: 20,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: con.maxWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: textColor ?? colors.white,
                          ),
                        ),
                      ),
                      if (image.isNotEmpty)
                        SizedBox(
                          width: con.maxWidth * 0.3,
                          child: CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                            placeholder: (context, url) =>
                                const SizedBox.shrink(),
                            errorWidget: (context, url, error) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      const Spacer(),
                      // ponytail: the chip is inert — the feed sends the
                      // category's id and name but no slug, and category
                      // details fetches by slug. Wire the tap once the payload
                      // carries `category_slug`.
                      if (showViewAll)
                        HomeViewAllWidget(
                          size: con.maxWidth * 0.04,
                          startBackgroundColor: accent.withValues(alpha: 0.3),
                          endBackgroundColor: accent.withValues(alpha: 0.1),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsetsDirectional.only(start: 16),
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
