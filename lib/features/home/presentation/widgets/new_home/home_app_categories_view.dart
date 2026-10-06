import 'dart:async';

import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/enums/loading_view_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';

/// [imageUrl] is null only for the loading skeletons, which stay blank circles.
typedef _CarouselItem = ({String label, String? imageUrl, VoidCallback? onTap});

/// The home categories carousel, rendered from the `categories` section of the
/// `/api/v1/home-sections` feed — its items, in the order the admin arranged
/// them. Empty (the feed is still loading) shows blank placeholders so the
/// header keeps its layout; a loaded but empty section is not built at all
/// (see `HomeView`).
class HomeAppCategoriesView extends ConsumerWidget {
  const HomeAppCategoriesView({super.key, required this.categories});

  final List<CategoryModel> categories;

  static const int _maxItems = 5;

  /// Category details queries its products and stores by `slug`, which the feed
  /// items do not carry — so it is taken from the app-wide categories list,
  /// matched by id. That list is preloaded on the splash and kept alive, so
  /// this is a lookup in memory, not another request.
  // ponytail: id → slug lookup; delete once `/home-sections` sends `slug`.
  CategoryModel _withSlug(WidgetRef ref, CategoryModel category) {
    if (category.slug != null) return category;
    final PaginationModel<CategoryModel>? page = ref
        .read(getAppCategoriesProvider)
        .valueOrNull;
    for (final CategoryModel known in page?.data ?? const <CategoryModel>[]) {
      if (known.id != null && known.id == category.id) return known;
    }
    return category;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<_CarouselItem> items = categories
        .take(_maxItems)
        .map(
          (CategoryModel category) => (
            label: context.getLocalizedApiText(category.name),
            // '' (not null): a real category without an image shows the
            // "failed to load image" placeholder; null is a loading skeleton.
            imageUrl: category.image ?? '',
            onTap: () {
              final CategoryModel target = _withSlug(ref, category);
              final String? slug = target.slug;
              if (slug == null) return;
              context.pushNamed(
                AppRoutes.categoryDetailsScreen,
                pathParameters: <String, String>{'slug': slug},
                extra: target.name,
              );
            },
          ),
        )
        .toList();

    final List<_CarouselItem> shown = items.isEmpty ? _placeholderItems : items;
    final bool loops = shown.length >= _CategoriesCarousel.minLoopingItems;
    // Keyed on the mode, so placeholders giving way to a short list start a
    // fresh carousel instead of keeping the looping one's page and timer.
    return _CategoriesCarousel(
      key: ValueKey<bool>(loops),
      items: shown,
      loops: loops,
    );
  }

  static final List<_CarouselItem> _placeholderItems =
      List<_CarouselItem>.generate(
        _maxItems,
        (_) => (label: '', imageUrl: null, onTap: null),
      );
}

class _CategoriesCarousel extends StatefulWidget {
  const _CategoriesCarousel({
    super.key,
    required this.items,
    required this.loops,
  });

  /// About 3.8 pages fit at a 0.26 viewport fraction. Fewer items than that
  /// would repeat on screen if they looped (one category filled every slot), so
  /// they sit still instead.
  static const int minLoopingItems = 4;

  final List<_CarouselItem> items;

  /// Endless and auto-sliding, or one page per item and still.
  final bool loops;

  @override
  State<_CategoriesCarousel> createState() => _CategoriesCarouselState();
}

class _CategoriesCarouselState extends State<_CategoriesCarousel> {
  static const int _initialPage = 10000;
  static const Duration _slideInterval = Duration(seconds: 5);
  static const Duration _slideDuration = Duration(milliseconds: 900);

  late final PageController _controller;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: widget.loops ? _initialPage : 0,
      viewportFraction: 0.26,
    );

    if (!widget.loops) return;
    _autoSlideTimer = Timer.periodic(_slideInterval, (_) {
      if (!_controller.hasClients) return;
      _controller.nextPage(duration: _slideDuration, curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final List<_CarouselItem> items = widget.items;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        return SizedBox(
          height: width * 0.42,
          child: PageView.builder(
            controller: _controller,
            physics: const BouncingScrollPhysics(),

            reverse: true,
            itemCount: widget.loops ? null : items.length,
            itemBuilder: (context, index) {
              final _CarouselItem item = items[index % items.length];
              return _CategoryCarouselItem(
                controller: _controller,
                index: index,
                width: width,
                label: item.label,
                imageUrl: item.imageUrl,
                onTap: item.onTap,
                colors: colors,
              );
            },
          ),
        );
      },
    );
  }
}

class _CategoryCarouselItem extends StatelessWidget {
  const _CategoryCarouselItem({
    required this.controller,
    required this.index,
    required this.width,
    required this.label,
    required this.imageUrl,
    required this.onTap,
    required this.colors,
  });

  final PageController controller;
  final int index;
  final double width;
  final String label;
  final String? imageUrl;
  final VoidCallback? onTap;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final double diameter = width * 0.26;

    final double minImageSize = diameter * 0.5;
    final double maxImageSize = diameter * 1.2;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final bool ready =
              controller.hasClients && controller.position.haveDimensions;
          final double page = ready
              ? controller.page!
              : controller.initialPage.toDouble();
          final double distance = (page - index).abs().clamp(0.0, 1.0);
          final double proximity = 1.0 - distance;
          final double scale = 1.0 - distance * 0.32;
          final double rawImageSize =
              minImageSize + (maxImageSize - minImageSize) * proximity;

          final bool isCentered = rawImageSize > diameter;
          final double padding = diameter * 0.14;
          final double imageSize = isCentered
              ? rawImageSize
              : rawImageSize.clamp(minImageSize, diameter - padding * 2);
          return Transform.scale(
            scale: scale,

            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: diameter,
                    height: diameter,
                    padding: EdgeInsets.all(diameter * 0.1),
                    clipBehavior: imageSize > diameter
                        ? Clip.none
                        : Clip.antiAlias,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.white, colors.onSecondaryFixed],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.5, 1],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: OverflowBox(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                      alignment: Alignment.center,

                      // Decoded once, at the largest size the slide ever
                      // draws, and scaled down by the FittedBox: keyed on the
                      // animated size, every frame of every slide was a new
                      // cache entry — a fresh decode of all five images.
                      child: imageUrl == null
                          ? null
                          : SizedBox.square(
                              dimension: imageSize,
                              child: FittedBox(
                                child: AppCachedNetworkImage(
                                  imageUrl: imageUrl!,
                                  width: maxImageSize,
                                  height: maxImageSize,
                                  fit: BoxFit.contain,
                                  placeholderType: LoadingViewTypes.circular,
                                  circularProgressSize: maxImageSize * 0.3,
                                  // The circle's gradient shows through.
                                  errorBackgroundColor: Colors.transparent,
                                ),
                              ),
                            ),
                    ),
                  ),

                  if (label.isNotEmpty) ...[
                    SizedBox(height: width * 0.02),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: width * 0.042,
                        fontWeight: isCentered
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: colors.black,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
