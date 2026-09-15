import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';







class BlockingLoadingOverlay extends StatelessWidget {
  const BlockingLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
  });

  final Widget child;



  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Stack(
      children: [
        AbsorbPointer(absorbing: isLoading, child: child),
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: colors.white.withValues(alpha: 0.6),
              child: Center(
                child: CircularProgressIndicator(color: colors.primary500Main),
              ),
            ),
          ),
      ],
    );
  }
}
