import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/bottom_concave_arc_clipper.dart';

class ProductImagesHeader extends StatelessWidget {
  const ProductImagesHeader({
    super.key,
    required this.topPadding,
    required this.fadeProgress,
    required this.child,
  });

  final double topPadding;
  final ValueListenable<double> fadeProgress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return ValueListenableBuilder<double>(
      valueListenable: fadeProgress,
      builder: (_, double progress, Widget? child) => Container(
        height: MediaQuery.sizeOf(context).height * 0.4,
        foregroundDecoration: BoxDecoration(
          color: colors.white.withValues(alpha: progress),
        ),
        child: child,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipPath(
            clipper: const BottomConcaveArcClipper(),
            child: ColoredBox(color: colors.neutral200),
          ),
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: child,
          ),
        ],
      ),
    );
  }
}
