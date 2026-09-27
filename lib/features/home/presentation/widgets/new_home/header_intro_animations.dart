import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// The header's "quick delivery" and "see all" intros, rebuilt natively from
/// the animated SVGs they used to be. Those were 0.7–3.8 MB each — full-size
/// PNGs drawn at ~100 px — and `full_svg_flutter` re-parsed and re-decoded them
/// on the UI thread on every mount. The images are now pre-cropped to their SVG
/// clip rects at 3× (sharp on any phone, since each canvas is drawn at ≤1×),
/// and every value below is copied from the SVGs' CSS `@keyframes`.

/// One CSS keyframe: at `percent` of the run the value is `value`, and `curve`
/// is that keyframe's `animation-timing-function` — CSS applies it from this
/// keyframe to the next one. The SVGs' animation-level function is linear.
(double, double, Curve) _k(
  double percent,
  double value, [
  Curve curve = Curves.linear,
]) => (percent, value, curve);

/// A CSS `@keyframes` track, first keyframe at 0% and last at 100%, as an
/// [Animatable] over the whole run.
Animatable<double> _keyframes(List<(double, double, Curve)> frames) =>
    TweenSequence<double>(<TweenSequenceItem<double>>[
      for (int i = 1; i < frames.length; i++)
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: frames[i - 1].$2,
            end: frames[i].$2,
          ).chain(CurveTween(curve: frames[i - 1].$3)),
          weight: frames[i].$1 - frames[i - 1].$1,
        ),
    ]);

/// Lays [children] out on an SVG's own [canvas] and fits it into the parent
/// the way `AnimatedSvgPicture(fit: contain)` did: the box takes the canvas
/// size clamped to the parent's constraints, and the canvas is contained and
/// centred in it. Unclipped, like the SVGs' `overflow: visible`.
Widget _svgCanvas(Size canvas, List<Widget> children) => SizedBox.fromSize(
  size: canvas,
  child: FittedBox(
    child: SizedBox.fromSize(
      size: canvas,
      child: Stack(clipBehavior: Clip.none, children: children),
    ),
  ),
);

/// Where one locale's SVG put things, in SVG units.
typedef _QuickDeliveryLayout = ({
  Size canvas,
  List<(AssetGenImage, Rect)> images,
  Offset shimmer,
});

final _QuickDeliveryLayout _english = (
  canvas: const Size(431, 120),
  images: <(AssetGenImage, Rect)>[
    (
      Assets.media.images.png.quickDeliveryEn1,
      const Rect.fromLTWH(157, 22, 118, 65),
    ),
    (
      Assets.media.images.png.quickDeliveryEn2,
      const Rect.fromLTWH(131, 11, 169, 99),
    ),
    (
      Assets.media.images.png.quickDeliveryEn3,
      const Rect.fromLTWH(42, 1, 347, 118),
    ),
  ],
  shimmer: const Offset(196, 16),
);

final _QuickDeliveryLayout _arabic = (
  canvas: const Size(390, 88),
  images: <(AssetGenImage, Rect)>[
    (
      Assets.media.images.png.quickDeliveryAr1,
      const Rect.fromLTWH(145.228, 11.52, 99, 65.237),
    ),
    (
      Assets.media.images.png.quickDeliveryAr2,
      const Rect.fromLTWH(113.228, -5.48, 163.138, 99),
    ),
    (
      Assets.media.images.png.quickDeliveryAr3,
      const Rect.fromLTWH(21.228, -5, 346.702, 99),
    ),
  ],
  shimmer: const Offset(175.228, 0),
);

/// "Fast delivery" → "Your order" → "will arrive in 15 minutes", each scaling
/// up from 0.8 as it fades in, then a shimmer sweeping over the last line.
/// Runs once (12 s) and holds its final frame.
class QuickDeliveryAnimation extends StatefulWidget {
  const QuickDeliveryAnimation({super.key});

  /// Opacity of the three lines, in order; the same in both locales. Each
  /// line's scale runs on the same keyframes, from 0.8 to 1, so it is derived
  /// from its opacity instead of spelled out twice.
  @visibleForTesting
  static final List<Animatable<double>> imageOpacities = <Animatable<double>>[
    _keyframes(<(double, double, Curve)>[
      _k(0, 0),
      _k(12.5, 0, Curves.ease),
      _k(17.25, 1),
      _k(33.33, 1, Curves.ease),
      _k(37.5, 0),
      _k(100, 0),
    ]),
    _keyframes(<(double, double, Curve)>[
      _k(0, 0),
      _k(33.33, 0, Curves.ease),
      _k(37.5, 1),
      _k(54.17, 1, Curves.ease),
      _k(58.33, 0),
      _k(100, 0),
    ]),
    _keyframes(<(double, double, Curve)>[
      _k(0, 0),
      _k(54.17, 0, Curves.ease),
      _k(58.33, 1),
      _k(100, 1),
    ]),
  ];

  static const double _sweep = 173.544;

  /// Five sweeps, alternating direction, starting at 56.67%.
  static final Animatable<double> _shimmerX =
      _keyframes(<(double, double, Curve)>[
        _k(0, 0),
        _k(56.67, 0, Curves.ease),
        _k(63.33, _sweep),
        _k(65.83, _sweep, Curves.ease),
        _k(72.5, 0),
        _k(75, 0, Curves.ease),
        _k(81.67, _sweep),
        _k(84.17, _sweep, Curves.ease),
        _k(90.83, 0),
        _k(93.33, 0, Curves.ease),
        _k(100, _sweep),
      ]);

  static final Animatable<double> _shimmerOpacity =
      _keyframes(<(double, double, Curve)>[
        _k(0, 0),
        _k(56.67, 0, Curves.ease),
        _k(57.08, 1),
        _k(62.92, 1, Curves.ease),
        _k(63.33, 0),
        _k(65.83, 0, Curves.ease),
        _k(66.25, 1),
        _k(72.08, 1, Curves.ease),
        _k(72.5, 0),
        _k(75, 0, Curves.ease),
        _k(75.42, 1),
        _k(81.25, 1, Curves.ease),
        _k(81.67, 0),
        _k(84.17, 0, Curves.ease),
        _k(84.58, 1),
        _k(90.42, 1, Curves.ease),
        _k(90.83, 0),
        _k(93.33, 0, Curves.ease),
        _k(93.75, 1),
        _k(99.58, 1, Curves.ease),
        _k(100, 0),
      ]);

  @override
  State<QuickDeliveryAnimation> createState() => _QuickDeliveryAnimationState();
}

class _QuickDeliveryAnimationState extends State<QuickDeliveryAnimation>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _scale = Tween<double>(begin: 0.8, end: 1);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..forward();

  late final List<Animation<double>> _opacities = <Animation<double>>[
    for (final Animatable<double> track
        in QuickDeliveryAnimation.imageOpacities)
      _controller.drive(track),
  ];
  late final Animation<double> _shimmerX = _controller.drive(
    QuickDeliveryAnimation._shimmerX,
  );
  late final Animation<double> _shimmerOpacity = _controller.drive(
    QuickDeliveryAnimation._shimmerOpacity,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final _QuickDeliveryLayout layout = context.isRTL ? _arabic : _english;
    return _svgCanvas(layout.canvas, <Widget>[
      for (int i = 0; i < layout.images.length; i++)
        Positioned.fromRect(
          rect: layout.images[i].$2,
          child: ScaleTransition(
            scale: _opacities[i].drive(_scale),
            child: layout.images[i].$1.image(
              fit: BoxFit.fill,
              opacity: _opacities[i],
            ),
          ),
        ),
      Positioned(
        left: layout.shimmer.dx,
        top: layout.shimmer.dy,
        width: 40,
        height: 88,
        child: AnimatedBuilder(
          animation: _shimmerX,
          builder: (context, child) => Transform.translate(
            offset: Offset(_shimmerX.value, 0),
            child: child,
          ),
          child: FadeTransition(
            opacity: _shimmerOpacity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    colors.white.withValues(alpha: 0),
                    colors.white.withValues(alpha: 0.4),
                    colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

/// "See all": hidden until 9.35% of its 2 s, then eases up 20 units, from
/// 0.95 to full size, fading in by 49.35%. Runs once and holds.
class SeeAllAnimation extends StatefulWidget {
  const SeeAllAnimation({super.key});

  @override
  State<SeeAllAnimation> createState() => _SeeAllAnimationState();
}

class _SeeAllAnimationState extends State<SeeAllAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..forward();

  // Opacity, rise and scale share these keyframes, so one progress drives all.
  late final Animation<double> _progress = _controller.drive(
    _keyframes(<(double, double, Curve)>[
      _k(0, 0),
      _k(9.35, 0, Curves.ease),
      _k(49.35, 1),
      _k(100, 1),
    ]),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AssetGenImage image = context.isRTL
        ? Assets.media.images.png.seeAllAr
        : Assets.media.images.png.seeAllEn;
    return _svgCanvas(const Size(127, 52), <Widget>[
      Positioned.fill(
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, 20 * (1 - _progress.value)),
            child: Transform.scale(
              scale: 0.95 + 0.05 * _progress.value,
              child: child,
            ),
          ),
          child: image.image(fit: BoxFit.fill, opacity: _progress),
        ),
      ),
    ]);
  }
}
