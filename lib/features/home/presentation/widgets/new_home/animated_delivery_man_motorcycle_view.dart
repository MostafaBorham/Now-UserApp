import 'package:anim_svg/anim_svg.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

/// Plays the delivery-man-on-a-motorcycle SVG with its native CSS `@keyframes`
/// animation intact.
///
/// `flutter_svg` renders only a single static frame of a CSS-animated SVG, so
/// we use [AnimSvgView], which transpiles the SVG to Lottie at runtime and
/// plays it. It already frees its native handle while off-screen; we add a
/// [RepaintBoundary] so the looping animation never repaints the rest of the
/// home page, and fall back to the static SVG if the native conversion is
/// unavailable on the current platform.
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

        Widget staticFallback() =>
            Assets.media.images.svg.deliveryManMotocycle.svg(
              width: w,
              height: h,
              fit: BoxFit.contain,
            );

        return RepaintBoundary(
          child: AnimSvgView.asset(
            path,
            width: w,
            height: h,
            fit: BoxFit.contain,
            animate: true,
            repeat: true,
            loadingBuilder: (BuildContext context) => staticFallback(),
            placeholderBuilder: (BuildContext context) => staticFallback(),
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stack) =>
                    staticFallback(),
          ),
        );
      },
    );
  }
}
