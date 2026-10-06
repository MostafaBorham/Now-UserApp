import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/formatters/arabic_kashida_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_app_category_section_view.dart';
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
    this.onViewAllTap,
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

  /// Opens the section's category; see `openHomeCategory`.
  final VoidCallback? onViewAllTap;

  /// Design frame width the absolute positions below were measured against.
  static const double _designWidth = 390;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final Color accent = primaryColor ?? colors.error;
    final Color titleColor = textColor ?? colors.white;
    final String image = imageUrl ?? '';
    return LayoutBuilder(
      builder: (context, con) {
        final double s = con.maxWidth / _designWidth;
        final double waveTop = 24 * s;
        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: waveTop,
              bottom: 0,
              child: ReverseWidget(
                applyReverse: !context.isRTL,
                child: HomeCategoryWave(
                  wave: HomeCategoryWave.twoWave,
                  viewBox: HomeCategoryWave.twoWaveViewBox,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.803],
                    colors: [accent, colors.white],
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8 * s),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            top: waveTop + 20 * s,
                          ),
                          child: Text(
                            formatArabicKashida(
                              context.getLocalizedApiText(categoryModel.name),
                              count: 20,
                            ),
                            textAlign: TextAlign.start,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 17.486 * s,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                              color: titleColor,
                            ),
                          ),
                        ),
                      ),
                      if (image.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 96 * s,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (con.maxWidth - 32) / 2,
                            ),
                            child: FittedBox(
                              // FittedBox lays its child out unbounded, so the
                              // image needs its own (design 164×96) box.
                              child: AppCachedNetworkImage(
                                imageUrl: image,
                                width: 164 * s,
                                height: 96 * s,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (showViewAll) ...[
                        SizedBox(width: image.isNotEmpty ? 12 : 8),
                        Padding(
                          padding: EdgeInsetsDirectional.only(top: waveTop),
                          child: HomeViewAllWidget(
                            onTap: onViewAllTap,
                            size: con.maxWidth * 0.04,
                            textColor: titleColor,
                            startBackgroundColor: colors.white,
                            endBackgroundColor: accent.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(
                  height: 245 * s,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: productModels.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
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
          ],
        );
      },
    );
  }
}
