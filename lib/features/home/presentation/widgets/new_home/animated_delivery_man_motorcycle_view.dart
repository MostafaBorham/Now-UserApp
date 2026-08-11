import 'package:flutter/material.dart';
import 'package:full_svg_flutter/full_svg_flutter.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

/// Plays the delivery-man-on-a-motorcycle SVG with its native CSS `@keyframes`
/// animation intact.
///
/// `flutter_svg` renders only a single static frame of a CSS-animated SVG, so
/// we use [FSvgPicture], which auto-detects the embedded animation and plays
/// it on every platform (pure Dart, no native build step). We wrap it in a
/// [RepaintBoundary] so the looping animation never repaints the rest of the
/// home page, and show the static SVG while the animation is being prepared.
class AnimatedDeliveryManMotorcycleView extends StatelessWidget {
  const AnimatedDeliveryManMotorcycleView({super.key, this.width});

  /// Render width. Defaults to the available width; height follows the SVG's
  /// intrinsic aspect ratio so the banner is never distorted.
  final double? width;

  /// The SVG's intrinsic viewBox is 388 × 93.
  static const double _aspectRatio = 388 / 93;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints con) {
        final double w =
            width ?? (con.maxWidth.isFinite ? con.maxWidth : 388);
        final double h = w / _aspectRatio;
        final String path = Assets.media.images.svg.deliveryManMotocycle.path;

        return RepaintBoundary(
          child: FSvgPicture.asset(
            path,
            width: w,
            height: h,
            fit: BoxFit.contain,
            autoPlay: true,
            placeholderBuilder: (BuildContext context) =>
                Assets.media.images.svg.deliveryManMotocycle.svg(
                  width: w,
                  height: h,
                  fit: BoxFit.contain,
                ),
          ),
        );
      },
    );
  }
}
