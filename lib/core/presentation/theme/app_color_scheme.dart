import 'package:flutter/material.dart';

class AppColorScheme {
  const AppColorScheme(this._scheme);

  final ColorScheme _scheme;

  Color get primary => _scheme.primary;
  Color get onPrimary => _scheme.onPrimary;
  Color get primaryContainer => _scheme.primaryContainer;
  Color get onPrimaryContainer => _scheme.onPrimaryContainer;
  Color get primaryFixed => _scheme.primaryFixed;
  Color get primaryFixedDim => _scheme.primaryFixedDim;
  Color get onPrimaryFixed => _scheme.onPrimaryFixed;
  Color get onPrimaryFixedVariant => _scheme.onPrimaryFixedVariant;
  Color get inversePrimary => _scheme.inversePrimary;

  Color get secondary => _scheme.secondary;
  Color get onSecondary => _scheme.onSecondary;
  Color get secondaryContainer => _scheme.secondaryContainer;
  Color get onSecondaryContainer => _scheme.onSecondaryContainer;
  Color get secondaryFixed => _scheme.secondaryFixed;
  Color get secondaryFixedDim => _scheme.secondaryFixedDim;
  Color get onSecondaryFixed => _scheme.onSecondaryFixed;
  Color get onSecondaryFixedVariant => _scheme.onSecondaryFixedVariant;

  Color get tertiary => _scheme.tertiary;
  Color get onTertiary => _scheme.onTertiary;
  Color get tertiaryContainer => _scheme.tertiaryContainer;
  Color get onTertiaryContainer => _scheme.onTertiaryContainer;
  Color get tertiaryFixed => _scheme.tertiaryFixed;
  Color get tertiaryFixedDim => _scheme.tertiaryFixedDim;
  Color get onTertiaryFixed => _scheme.onTertiaryFixed;
  Color get onTertiaryFixedVariant => _scheme.onTertiaryFixedVariant;

  Color get error => _scheme.error;
  Color get onError => _scheme.onError;
  Color get errorContainer => _scheme.errorContainer;
  Color get onErrorContainer => _scheme.onErrorContainer;

  Color get surface => _scheme.surface;
  Color get onSurface => _scheme.onSurface;
  Color get surfaceBright => _scheme.surfaceBright;
  Color get onSurfaceVariant => _scheme.onSurfaceVariant;
  Color get surfaceContainerLowest => _scheme.surfaceContainerLowest;
  Color get surfaceContainerLow => _scheme.surfaceContainerLow;
  Color get surfaceContainerHigh => _scheme.surfaceContainerHigh;
  Color get surfaceContainerHighest => _scheme.surfaceContainerHighest;

  Color get outline => _scheme.outline;
  Color get outlineVariant => _scheme.outlineVariant;
  Color get scrim => _scheme.scrim;
}

extension BuildContextColors on BuildContext {
  AppColorScheme get colors => AppColorScheme(Theme.of(this).colorScheme);
}