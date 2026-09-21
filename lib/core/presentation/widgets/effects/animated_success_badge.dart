import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

/// A circular image badge that lands with a green success glow and a check
/// mark, with its [label] rising in beneath it — the confirmation flourish
/// shared by the "added to cart" sheet and the "rate your order" prompt.
///
/// The whole entrance is one 1.2s pass played once. Each element owns a slice
/// of that timeline, matching the Figma motion spec: the image circle pops in
/// first, its green glow fades up behind it, then the check badge and the label
/// arrive.
class AnimatedSuccessBadge extends StatefulWidget {
  const AnimatedSuccessBadge({
    super.key,
    required this.imageUrl,
    required this.label,
  });

  final String imageUrl;
  final String label;

  @override
  State<AnimatedSuccessBadge> createState() => _AnimatedSuccessBadgeState();
}

class _AnimatedSuccessBadgeState extends State<AnimatedSuccessBadge>
    with SingleTickerProviderStateMixin {
  static const Cubic _overshoot = Cubic(0.34, 1.2, 0.64, 1);
  static const Cubic _easeOut = Cubic(0.16, 1, 0.3, 1);
  static const Cubic _textEase = Cubic(0.22, 1, 0.36, 1);

  static const Interval _circlePop = Interval(0, 0.375, curve: _overshoot);
  static const Interval _circleFade = Interval(0, 0.125, curve: _easeOut);
  static const Interval _glowFade = Interval(0.4167, 0.6667, curve: _easeOut);
  static const Interval _badgePop = Interval(0.2917, 0.5, curve: _overshoot);
  static const Interval _badgeFade = Interval(0.2917, 0.4167);
  static const Interval _nameFade = Interval(0, 0.3333, curve: _textEase);
  static const Interval _nameRise = Interval(0, 0.4167, curve: _textEase);
  static const Interval _namePop = Interval(0, 0.5, curve: Curves.easeOutBack);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => _buildBadge(colors),
        ),
        8.hSpace,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double t = _controller.value;
            return Opacity(
              opacity: _nameFade.transform(t),
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - _nameRise.transform(t))),
                child: Transform.scale(
                  scale: 0.5 + 0.5 * _namePop.transform(t),
                  child: child,
                ),
              ),
            );
          },
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.visible,
            style: AppTextStyles.style14Medium.copyWith(color: colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(AppColorScheme colors) {
    final double t = _controller.value;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: colors.primary500Main.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
        ),
        Opacity(
          opacity: _circleFade.transform(t),
          child: Transform.scale(
            scale: _circlePop.transform(t),
            child: Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.primary500Main.withValues(
                      alpha: 0.35 * _glowFade.transform(t),
                    ),
                    offset: const Offset(0, 10),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: ClipOval(
                child: AppCachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          start: 0,
          bottom: 17,
          child: Opacity(
            opacity: _badgeFade.transform(t),
            child: Transform.scale(
              scale: _badgePop.transform(t),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors.primary500Main,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 11, color: colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
