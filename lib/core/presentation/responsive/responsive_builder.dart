import 'package:flutter/widgets.dart';

import 'responsive_config.dart';

/// Wraps [child] in a `LayoutBuilder` and publishes the active
/// [ResponsiveConfig] so any descendant can scale sizes with the `.sf`
/// extension on `num`.
///
/// Give it the figma frame the child was designed against via [figmaWidth] and
/// [figmaHeight]; the available width/height are read from the layout
/// constraints. Inside [child], call `.sf` on any number to get a size scaled
/// uniformly to the current constraints, e.g.
///
/// ```dart
/// ResponsiveBuilder(
///   figmaWidth: 390,
///   figmaHeight: 844,
///   child: Column(
///     children: [
///       Text('Title', style: TextStyle(fontSize: 20.sf)),
///       SizedBox(height: 12.sf),
///     ],
///   ),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.figmaWidth,
    required this.figmaHeight,
    required this.child,
  });

  /// The reference width of the figma frame [child] was designed against.
  final double figmaWidth;

  /// The reference height of the figma frame [child] was designed against.
  final double figmaHeight;

  /// The subtree whose descendants may use the `.sf` extension.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Fall back to the surrounding media size when a constraint is
        // unbounded (e.g. inside a scroll view along the scroll axis).
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
