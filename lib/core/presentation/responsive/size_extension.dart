import 'responsive_config.dart';

/// Responsive sizing on any number, driven by the nearest [ResponsiveBuilder].
///
/// Use it for font sizes, paddings, radii, icon sizes, etc.:
///
/// ```dart
/// Text('Hello', style: TextStyle(fontSize: 20.sf));
/// SizedBox(height: 16.sf);
/// ```
///
/// The value is scaled from the figma design space to the available space via
/// [ResponsiveConfig.scale]. When there is no [ResponsiveBuilder] above the
/// caller, the original value is returned unchanged.
extension ResponsiveSize on num {
  /// Scaled by a combination of width and height (geometric mean).
  double get sf {
    final config = ResponsiveConfig.current;
    if (config == null) return toDouble();
    return config.scale(this);
  }

  /// Scaled by the width ratio only — grows/shrinks with horizontal space.
  double get sw {
    final config = ResponsiveConfig.current;
    if (config == null) return toDouble();
    return config.scaleWidth(this);
  }

  /// Scaled by the height ratio only — grows/shrinks with vertical space.
  double get sh {
    final config = ResponsiveConfig.current;
    if (config == null) return toDouble();
    return config.scaleHeight(this);
  }
}
