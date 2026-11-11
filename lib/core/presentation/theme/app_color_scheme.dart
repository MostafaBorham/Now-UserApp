import 'package:flutter/material.dart';

class AppColorScheme {
  const AppColorScheme(this._scheme);

  final ColorScheme _scheme;

  Color get primary500Main => _scheme.primary;
  Color get white => _scheme.onPrimary;
  Color get primaryContainer => _scheme.primaryContainer;
  Color get onPrimaryContainer => _scheme.onPrimaryContainer;
  Color get primaryFixed => _scheme.primaryFixed;
  Color get primaryFixedDim => _scheme.primaryFixedDim;
  Color get onPrimaryFixed => _scheme.onPrimaryFixed;
  Color get inverseSurface => _scheme.inverseSurface;
  Color get primary700 => _scheme.onPrimaryFixedVariant;
  Color get neutral400 => _scheme.inversePrimary;

  Color get secondary600 => _scheme.secondary;
  Color get black => _scheme.onSecondary;
  Color get secondaryContainer => _scheme.secondaryContainer;
  Color get amber500 => _scheme.onSecondaryContainer;
  Color get secondaryFixed => _scheme.secondaryFixed;
  Color get secondaryFixedDim => _scheme.secondaryFixedDim;
  Color get onSecondaryFixed => _scheme.onSecondaryFixed;
  Color get onSecondaryFixedVariant => _scheme.onSecondaryFixedVariant;

  Color get primary200 => _scheme.tertiary;
  Color get onTertiary => _scheme.onTertiary;
  Color get tertiaryContainer => _scheme.tertiaryContainer;
  Color get onTertiaryContainer => _scheme.onTertiaryContainer;
  Color get tertiaryFixed => _scheme.tertiaryFixed;
  Color get neutral300 => _scheme.tertiaryFixedDim;
  Color get neutral1200 => _scheme.onTertiaryFixed;
  Color get secondary100 => _scheme.onTertiaryFixedVariant;

  Color get error => _scheme.error;
  Color get onError => _scheme.onError;
  Color get errorContainer => _scheme.errorContainer;
  Color get onErrorContainer => _scheme.onErrorContainer;

  Color get surface => _scheme.surface;
  Color get onInverseSurface => _scheme.onInverseSurface;
  Color get neutral500 => _scheme.onSurface;
  Color get surfaceBright => _scheme.surfaceBright;
  Color get primary100 => _scheme.onSurfaceVariant;
  Color get surfaceContainerLowest => _scheme.surfaceContainerLowest;
  Color get neutral200 => _scheme.surfaceContainerLow;
  Color get dividerLight => const Color(0xffF0F0F0);
  Color get surfaceContainerHigh => _scheme.surfaceContainerHigh;
  Color get surfaceContainerHighest => _scheme.surfaceContainerHighest;

  Color get outline => _scheme.outline;
  Color get outlineVariant => _scheme.outlineVariant;
  Color get scrim => _scheme.scrim;

  Color get sky500 => const Color(0xff0EA5E9);
  Color get orange500 => const Color(0xffF59E0B);
  Color get orange100 => const Color(0xffFFEDD4);
  Color get deepOrange400 => const Color(0xffFF7043);

  Color get red400 => const Color(0xffB91828);

  Color get red300Main => const Color(0xffE32B3D);

  Color get green300Main => const Color(0xff1ED29C);

  Color get green500 => const Color(0xff117456);

  Color get orange900 => const Color(0xff923E0E);

  Color get purple200 => const Color(0xffBAB3FF);
  Color get purple800 => const Color(0xff43368E);
  Color get neutral100 => _scheme.onPrimaryContainer;
  Color get saudiMainColor => const Color(0xff006C35);
  Color get purple400 => const Color(0xff8375FF);
  Color get purple950 => const Color(0xff2F1866);
  Color get lightBlue100 => const Color(0xffC3E2F0);
  Color get lightBlue900 => const Color(0xff00557B);
  Color get lightBlueA400 => const Color(0xff00B0FF);
  Color get neutral1000 => const Color(0xff303030);
  Color get neutral1100 => const Color(0xff1A1A1A);
  Color get red500 => const Color(0xff83111C);
  Color get redAlpha10 => const Color(0x1AE32B3D);
  Color get yellowAlpha10 => const Color(0x1AFFD008);
  Color get yellowDarkText => const Color(0xff806400);
  Color get greyText => const Color(0xff686868);
  Color get greyMutedText => const Color(0xff888888);
  Color get ratingBar => const Color(0xffF5A523);
}

extension BuildContextColors on BuildContext {
  AppColorScheme get colors => AppColorScheme(Theme.of(this).colorScheme);
}
