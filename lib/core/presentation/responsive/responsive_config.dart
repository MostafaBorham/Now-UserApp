import 'dart:math' as math;

class ResponsiveConfig {
  const ResponsiveConfig({
    required this.figmaWidth,
    required this.figmaHeight,
    required this.maxWidth,
    required this.maxHeight,
  });

  final double figmaWidth;

  final double figmaHeight;

  final double maxWidth;

  final double maxHeight;

  static ResponsiveConfig? current;

  double scale(num size) {
    final widthScale = maxWidth / figmaWidth;
    final heightScale = maxHeight / figmaHeight;
    final scaleFactor = math.sqrt(widthScale * heightScale);
    return scaleFactor * size;
  }

  double scaleWidth(num size) => (maxWidth / figmaWidth) * size;

  double scaleHeight(num size) => (maxHeight / figmaHeight) * size;
}
