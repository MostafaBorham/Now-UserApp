import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';

/// A single item fed to the carousel: a display [label], its [imageUrl] and the
/// [onTap] that opens it.
/// [imageUrl] is nullable — a `null` (or unresolvable) image renders nothing in
/// the image slot rather than falling back to a stand-in. [onTap] is null for
/// the loading / error placeholders, so only real (data) items are tappable.
typedef _CarouselItem = ({String label, String? imageUrl, VoidCallback? onTap});

/// Auto-sliding categories carousel wired to [getAppCategoriesProvider].
///
/// This widget only watches the provider and maps the async state into the
/// carousel's item list, so it rebuilds solely on state transitions
/// (loading → data / error) — never on the per-frame slide animation, which
/// stays isolated inside [_CategoriesCarousel]. The carousel keeps the same
/// shape in every state; the only difference in the data state is that each
/// item carries the real category image and name.
///
/// The shared [getAppCategoriesProvider] is preloaded on the splash screen, so
/// this usually renders cached data with no fetch. If it is opened while that
/// shared state has no value (never loaded, or errored), `initState` refetches
/// it — flipping it to loading so the shimmer circles show first.
class HomeAppCategoriesView extends ConsumerStatefulWidget {
  const HomeAppCategoriesView({super.key});

  @override
  ConsumerState<HomeAppCategoriesView> createState() =>
      _HomeAppCategoriesViewState();
}

class _HomeAppCategoriesViewState extends ConsumerState<HomeAppCategoriesView> {
  // Placeholder count kept equal to the data cap so the modulo mapping — and
  // therefore the centred item — doesn't jump when real data replaces it.
  static const int _maxItems = 5;

  @override
  void initState() {
    super.initState();
    // The categories are normally preloaded on splash. Fetch here only if that
    // never happened or failed (no value yet) — an already-loaded list is kept
    // as-is (no refetch). So opening this while the shared provider is errored
    // flips it to loading first, and the shimmer circles are the first thing
    // shown rather than the error shape.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || ref.read(getAppCategoriesProvider).hasValue) return;
      ref.read(getAppCategoriesProvider.notifier).loadFirstPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PaginationModel<CategoryModel>> state = ref.watch(
      getAppCategoriesProvider,
    );

    final List<_CarouselItem> items = state.maybeWhen(
      data: (PaginationModel<CategoryModel> page) {
        final List<CategoryModel> categories = page.data
            .take(_maxItems)
            .toList();
        if (categories.isEmpty) return _placeholderItems;
        return categories
            .map(
              (CategoryModel category) => (
                label: context.getLocalizedApiText(category.name),
                // Null / broken image → empty image slot (see item builder).
                imageUrl: category.image,
                onTap: () => context.pushNamed(
                  AppRoutes.categoryDetailsScreen,
                  extra: category,
                ),
              ),
            )
            .toList();
      },
      orElse: () => _placeholderItems,
    );

    return _CategoriesCarousel(items: items);
  }

  // Loading / error shape: bare circles only — no image (null → empty slot)
  // and no label (empty → the name is not built). The data state is the only
  // one that fills the circle and shows a name.
  static final List<_CarouselItem> _placeholderItems =
      List<_CarouselItem>.generate(
        _maxItems,
        (_) => (label: '', imageUrl: null, onTap: null),
      );
}

/// The auto-sliding carousel itself: the item nearest the viewport centre is
/// scaled up while the rest shrink, and the list keeps sliding on its own.
///
/// Owns the [PageController] and slide [Timer], so it survives the parent's
/// state-driven rebuilds and only picks up new [items] via [didUpdateWidget].
class _CategoriesCarousel extends StatefulWidget {
  const _CategoriesCarousel({required this.items});

  final List<_CarouselItem> items;

  @override
  State<_CategoriesCarousel> createState() => _CategoriesCarouselState();
}

class _CategoriesCarouselState extends State<_CategoriesCarousel> {
  // Start far from 0 so the list can slide in both directions endlessly.
  static const int _initialPage = 10000;
  static const Duration _slideInterval = Duration(seconds: 3);
  static const Duration _slideDuration = Duration(milliseconds: 900);

  late final PageController _controller;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: _initialPage,
      viewportFraction: 0.26,
    );
    // Dwell between slides: the controller stays idle and only animates for
    // the short nextPage() hop, keeping the carousel cheap to run.
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
            // Slide right-to-left in Arabic, left-to-right in English — see
            // the motion rule on `AppSlider`. The strip is an endless modulo
            // loop, so mirroring the page order costs nothing here.
            reverse: true,
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
          final double proximity = 1.0 - distance; // 0 at side → 1 at centre
          final double scale = 1.0 - distance * 0.32; // center 1.0 → side 0.68
          final double rawImageSize =
              minImageSize + (maxImageSize - minImageSize) * proximity;
          // The centre item is free to overflow the circle; every other item
          // is kept inside it with padding between the image and the edge.
          final bool isCentered = rawImageSize > diameter;
          final double padding = diameter * 0.14;
          final double imageSize = isCentered
              ? rawImageSize
              : rawImageSize.clamp(minImageSize, diameter - padding * 2);
          return Transform.scale(
            scale: scale,
            // Tappable only when there's a target (data items); the loading /
            // error placeholders pass a null onTap and stay inert.
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
                      // Null / empty url → nothing in the image slot; a load
                      // error collapses to the same empty slot via errorWidget.
                      child: (imageUrl == null || imageUrl!.isEmpty)
                          ? const SizedBox.shrink()
                          : CachedNetworkImage(
                              imageUrl: imageUrl!,
                              width: imageSize,
                              height: imageSize,
                              fit: BoxFit.contain,
                              placeholder: (context, url) =>
                                  const SizedBox.shrink(),
                              errorWidget: (context, url, error) =>
                                  const SizedBox.shrink(),
                            ),
                    ),
                  ),
                  // Loading / error carry no label, so the name (and its gap)
                  // are built only when there is one — leaving bare circles.
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
