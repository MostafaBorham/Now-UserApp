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
  double get sf {
    final config = ResponsiveConfig.current;
    if (config == null) return toDouble();
    return config.scale(this);
  }
}
