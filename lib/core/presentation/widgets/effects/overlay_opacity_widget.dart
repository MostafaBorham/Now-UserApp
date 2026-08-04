import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class OverlayOpacityWidget extends StatelessWidget {
  const OverlayOpacityWidget({
    super.key,
    required this.child,
    this.disabled = false,
    this.overlayColor,
  });

  final Widget child;
  final bool disabled;
  final Color? overlayColor;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return IgnorePointer(
      ignoring: disabled,
      child: Stack(
        children: [
          child,
          if (disabled)
            Positioned.fill(
              child: ColoredBox(
                color: overlayColor ??
                    colors.onPrimary.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
    );
  }
}