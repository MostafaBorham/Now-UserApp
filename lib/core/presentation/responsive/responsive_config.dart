import 'dart:math' as math;

/// Ambient responsive configuration published by [ResponsiveBuilder] and read
/// by the `.sf` extension on `num`.
///
/// An extension getter cannot access a `BuildContext`, so the active figma
/// design size and the current layout constraints are exposed here statically.
/// [ResponsiveBuilder] sets [current] inside its `LayoutBuilder` before the
/// child is built; `.sf` then reads it to compute a scaled size.
class ResponsiveConfig {
  const ResponsiveConfig({
    required this.figmaWidth,
    required this.figmaHeight,
    required this.maxWidth,
    required this.maxHeight,
  });

  /// The reference width of the figma frame the child was designed against.
  final double figmaWidth;

  /// The reference height of the figma frame the child was designed against.
  final double figmaHeight;

  /// The width available to the child, taken from the wrapping `LayoutBuilder`.
  final double maxWidth;

  /// The height available to the child, taken from the wrapping `LayoutBuilder`.
  final double maxHeight;

  /// The currently active config, or `null` when no [ResponsiveBuilder] is
  /// above the widget calling `.sf`.
  static ResponsiveConfig? current;

  /// Scales [size] from the figma design space into the available space using
  /// the smaller of the width/height scale factors (uniform scaling).
  double scale(num size) {
    final widthScale = maxWidth / figmaWidth;
    final heightScale = maxHeight / figmaHeight;
    final scaleFactor = math.min(widthScale, heightScale);
    return scaleFactor * size;
  }
}
