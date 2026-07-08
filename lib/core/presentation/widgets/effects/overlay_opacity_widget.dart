import 'package:flutter/material.dart';

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
    return IgnorePointer(
      ignoring: disabled,
      child: Stack(
        children: [
          child,
          if (disabled)
            Positioned.fill(
              child: ColoredBox(
                color: overlayColor ??
                    Colors.black.withValues(alpha: 0.35),
              ),
            ),
        ],
      ),
    );
  }
}