import 'package:flutter/widgets.dart';

import 'responsive_config.dart';

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.figmaWidth,
    required this.figmaHeight,
    required this.child,
  });

  final double figmaWidth;

  final double figmaHeight;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.sizeOf(context);
        final maxWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : media.width;
        final maxHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : media.height;

        ResponsiveConfig.current = ResponsiveConfig(
          figmaWidth: figmaWidth,
          figmaHeight: figmaHeight,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
        return child;
      },
    );
  }
}
