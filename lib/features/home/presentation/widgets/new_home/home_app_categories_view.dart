import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Auto-sliding categories carousel: the item nearest the viewport center is
/// scaled up while the rest shrink, and the list keeps sliding on its own.
class HomeAppCategoriesView extends StatefulWidget {
  const HomeAppCategoriesView({super.key});

  @override
  State<HomeAppCategoriesView> createState() => _HomeAppCategoriesViewState();
}

class _HomeAppCategoriesViewState extends State<HomeAppCategoriesView> {
  // Default remote image used for every item until the categories data layer
  // is wired in; the real category image URL will replace it after backend
  // integration.
  static const String _defaultImageUrl =
      'https://www.image2url.com/r2/default/images/1786526922724-862c11f3-bc42-4fbd-9dc5-7ffb95c3204b.png';

  // Placeholder content until the categories data layer is wired in.
  static const List<(String, String)> _categories = [
    ('المقاضي', _defaultImageUrl),
    ('الجمال', _defaultImageUrl),
    ('العطور', _defaultImageUrl),
    ('الموضة', _defaultImageUrl),
    ('إلكترونيات', _defaultImageUrl),
    ('الرياضة', _defaultImageUrl),
    ('المنزل', _defaultImageUrl),
  ];

  // Start far from 0 so the list can slide in both directions endlessly.
  static const int _initialPage = 10000;
  static const Duration _slideInterval = Duration(seconds: 3);
  static const Duration _slideDuration = Duration(milliseconds: 650);

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        return SizedBox(
          height: width * 0.42,
          child: PageView.builder(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final (String label, String imageUrl) =
                  _categories[index % _categories.length];
              return _CategoryCarouselItem(
                controller: _controller,
                index: index,
                width: width,
                label: label,
                imageUrl: imageUrl,
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
    required this.colors,
  });

  final PageController controller;
  final int index;
  final double width;
  final String label;
  final String imageUrl;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final double diameter = width * 0.26;
    // Image sizes: side items keep the image inside the circle; the centre item
    // grows the image past the circle so it overflows and sits over it.
    final double minImageSize = diameter * 0.5; // side slot — inside the circle
    final double maxImageSize = diameter * 1.2; // centre — exceeds the circle
    // RepaintBoundary keeps each item's per-frame scaling from repainting its
    // neighbours; only the Transform + image rebuild while the list slides.
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
          // As the item slides toward the centre the image grows from inside
          // the circle up to overflowing it, and shrinks back on the way out.
          final double imageSize =
              minImageSize + (maxImageSize - minImageSize) * proximity;
          return Transform.scale(
            scale: scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: diameter,
                  height: diameter,
                  // Clip the image to the circle for every normal item so it
                  // stays inside; only release the clip once the image has
                  // grown past the diameter (the centre item) so it can spill
                  // out. At the crossover the image exactly fills the circle,
                  // so toggling the clip is visually seamless.
                  clipBehavior:
                      imageSize > diameter ? Clip.none : Clip.antiAlias,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.white, colors.onSecondaryFixed],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.5, 1],
                    ),
                    shape: BoxShape.circle,
                  ),
                  // OverflowBox frees the image from the circle's size limit so
                  // the centre item can grow past the diameter, kept centred.
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    alignment: Alignment.center,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const SizedBox.shrink(),
                      errorWidget: (context, url, error) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),
                child!,
              ],
            ),
          );
        },
        // Static label subtree: reused across frames, never rebuilt.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: width * 0.02),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: width * 0.042,
                fontWeight: FontWeight.w600,
                color: colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
