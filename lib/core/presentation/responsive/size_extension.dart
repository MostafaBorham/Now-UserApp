import 'responsive_config.dart';

extension ResponsiveSize on num {
  double get sf {
    final config = ResponsiveConfig.current;
    if (config == null) return toDouble();
    return config.scale(this);
  }

  double get sw {
    final config = ResponsiveConfig.current;
    if (config == null) return toDouble();
    return config.scaleWidth(this);
  }

  double get sh {
    final config = ResponsiveConfig.current;
    if (config == null) return toDouble();
    return config.scaleHeight(this);
  }
}
