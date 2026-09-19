import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/formatters/arabic_kashida_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_view_all_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';

/// A `products_by_category` section in its `color_with_image` design: the
/// category name and the section's own artwork over a wave washed in
/// [primaryColor], with a row of that category's products beneath it.
///
/// Positions/sizes come from the Figma frame (390pt wide, node 7137:26670) and
/// are scaled by the available width so the section keeps the design's
/// proportions on any device.
class HomeAppCategoryWithLogoSectionView extends ConsumerWidget {
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

  /// Design frame width the absolute positions below were measured against.
  static const double _designWidth = 390;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final Color accent = primaryColor ?? colors.error;
    final String image = imageUrl ?? '';
    return LayoutBuilder(
      builder: (context, con) {
        final double s = con.maxWidth / _designWidth;
        return SizedBox(
          height: 317 * s,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Wave: bleeds the full width, solid accent at the top fading to
              // white at 80.3% (matches the Figma fill exactly).
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 316 * s,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (Rect bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.803],
                    colors: [accent, colors.white],
                  ).createShader(bounds),
                  child: ReverseWidget(
                    applyReverse: !context.isRTL,
                    child: Assets.media.images.svg.twoWaveBackground.svg(
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              // Category artwork, near the top and poking above the wave.
              // Directional so it mirrors with the layout: the design's Arabic
              // screen-x 51..215 maps to `start: 175` (390 − 215) from the
              // trailing edge.
              if (image.isNotEmpty)
                PositionedDirectional(
                  start: 175 * s,
                  top: -28 * s,
                  width: 164 * s,
                  height: 100 * s,
                  child: CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    placeholder: (context, url) => const SizedBox.shrink(),
                    errorWidget: (context, url, error) => const SizedBox.shrink(),
                  ),
                ),
              // Category name: two white kashida-stretched lines on the leading
              // side (right in Arabic). Design box is 43pt in from that edge.
              PositionedDirectional(
                start: 43 * s,
                top: 14 * s,
                width: 157 * s,
                child: Text(
                  formatArabicKashida(
                    context.getLocalizedApiText(categoryModel.name),
                    count: 20,
                  ),
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.486 * s,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: textColor ?? colors.white,
                  ),
                ),
              ),
              // See all, on the trailing side (left in Arabic).
              // ponytail: the chip is inert — the feed sends the category's id
              // and name but no slug, and category details fetches by slug. Wire
              // the tap once the payload carries `category_slug`.
              if (showViewAll)
                PositionedDirectional(
                  end: 16 * s,
                  top: 10 * s,
                  child: HomeViewAllWidget(
                    size: con.maxWidth * 0.04,
                    startBackgroundColor: accent.withValues(alpha: 0.3),
                    endBackgroundColor: accent.withValues(alpha: 0.1),
                  ),
                ),
              // Product rail, sitting on the white lower part of the wave.
              Positioned(
                left: 0,
                right: 0,
                top: 72 * s,
                bottom: 0,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: productModels.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => ProductItem3View(
                    product: productModels[index],
                    onFavouriteChanged: (bool isFavourite) => ref
                        .read(getHomeSectionsProvider.notifier)
                        .updateProductFavourite(
                          productModels[index].id,
                          isFavourite,
                        ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
