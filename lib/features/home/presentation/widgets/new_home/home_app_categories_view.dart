import 'dart:async';

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
  // Placeholder content until the categories data layer is wired in.
  static const List<(String, IconData)> _categories = [
    ('المقاضي', Icons.shopping_basket_rounded),
    ('الجمال', Icons.face_retouching_natural_rounded),
    ('العطور', Icons.local_florist_rounded),
    ('الموضة', Icons.checkroom_rounded),
    ('إلكترونيات', Icons.devices_other_rounded),
    ('الرياضة', Icons.sports_soccer_rounded),
    ('المنزل', Icons.chair_rounded),
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
              final (String label, IconData icon) =
                  _categories[index % _categories.length];
              return _CategoryCarouselItem(
                controller: _controller,
                index: index,
                width: width,
                label: label,
                icon: icon,
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
    required this.icon,
    required this.colors,
  });

  final PageController controller;
  final int index;
  final double width;
  final String label;
  final IconData icon;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final double diameter = width * 0.26;
    // RepaintBoundary keeps each item's per-frame scaling from repainting its
    // neighbours; only the Transform rebuilds while the list slides.
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final bool ready =
              controller.hasClients && controller.position.haveDimensions;
          final double page =
              ready ? controller.page! : controller.initialPage.toDouble();
          final double distance = (page - index).abs().clamp(0.0, 1.0);
          final double scale = 1.0 - distance * 0.32; // center 1.0 → side 0.68
          return Transform.scale(scale: scale, child: child);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: diameter,
              height: diameter,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.primaryFixed,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.primary200.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: diameter * 0.5,
                color: colors.primary700,
              ),
            ),
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
