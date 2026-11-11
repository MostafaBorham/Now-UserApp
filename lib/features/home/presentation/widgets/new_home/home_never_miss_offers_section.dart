import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/products/product_details_list_scope.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/lists/infinite_auto_scroll_list.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_never_miss_offers_item.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_view_all_widget.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';

/// The `flash_offers` section: an endlessly scrolling strip of the most deeply
/// discounted products, each card owning its own favourite and cart actions.
///
/// The heading is the design's own logo artwork (Arabic / English), not the
/// feed's `title` — the backend only titles text headings. It does colour the
/// section though: [backgroundColor] washes the top of the strip and
/// [viewAllTextColor] / [viewAllUnderlineColor] paint the "See All" chip. Each
/// falls back to the theme colour the design shipped with.
class HomeNeverMissOffersSection extends ConsumerWidget {
  const HomeNeverMissOffersSection({
    super.key,
    required this.products,
    this.backgroundColor,
    this.viewAllTextColor,
    this.viewAllUnderlineColor,
  });

  final List<ProductModel> products;
  final Color? backgroundColor;
  final Color? viewAllTextColor;
  final Color? viewAllUnderlineColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final Color background = backgroundColor ?? colors.inverseSurface;
    final Color viewAllUnderline =
        viewAllUnderlineColor ?? colors.inverseSurface;
    return ProductDetailsListScope(
      productSlugs: () => products.map((product) => product.slug),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [background.withValues(alpha: 0.9), colors.white],
                  stops: [0, 0.7],
                ),
              ),
              child: Assets.media.images.svg.homeNeverMissOffersBackground.svg(
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, con) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 5,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Spacer(),
                          context.isRTL
                              ? Assets.media.images.png.homeNeverMissOffersLogo
                                    .image(width: con.maxWidth * 0.35)
                              : Assets
                                    .media
                                    .images
                                    .png
                                    .englishOffersCannotMissLogo
                                    .image(width: con.maxWidth * 0.35),
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: HomeViewAllWidget(
                                size: 16,
                                startBackgroundColor: viewAllUnderline,
                                endBackgroundColor: viewAllUnderline.withValues(
                                  alpha: 0.7,
                                ),
                                textColor: viewAllTextColor ?? colors.white,
                                onTap: () => context.pushNamed(
                                  AppRoutes.homeNeverMissOffersScreen,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, listCon) {
                          final double itemHeight = listCon.maxHeight - 4;
                          return InfiniteAutoScrollList(
                            itemCount: products.length,
                            itemWidth: itemHeight * 0.55,
                            separatorWidth: 10,
                            // The same inset as the All stores cards (the section's
                            // 16 + the list's 5), so the first card no longer
                            // touches the screen edge.
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              21,
                              0,
                              21,
                              4,
                            ),
                            itemBuilder: (context, index) =>
                                HomeNeverMissOffersItem(
                                  product: products[index],
                                  onFavouriteChanged: (bool isFavourite) => ref
                                      .read(getHomeSectionsProvider.notifier)
                                      .updateProductFavourite(
                                        products[index].id,
                                        isFavourite,
                                      ),
                                ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
