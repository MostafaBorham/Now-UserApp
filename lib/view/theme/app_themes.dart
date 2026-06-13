import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/assets/fonts.gen.dart';

abstract class AppThemes {
  static ThemeData getLightModeTheme() => ThemeData(
    fontFamily: FontFamily.ibmPlexSans,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: Color(0xff4BB749),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      error: Colors.red,
      onSecondaryFixed: Color(0xffFCE041),
      onPrimaryContainer: Color(0xffF5F5F5),
      secondary: Color(0xffEAD800),
      inversePrimary: Color(0xffB8B8B8),
      inverseSurface: Color(0xff01CE21),
      errorContainer: Color(0xffE7000B),
      onSecondaryContainer: Color(0xffFD9A00),
      onSurface: Color(0xffA1A1A1),
      onPrimaryFixed: Color(0xff404040),
      onTertiary: Color(0xffE9C600),
      onTertiaryFixed: Color(0xff030303),
      tertiary: Color(0xffB7E2B6),
      onInverseSurface: Colors.orange,
    ),
  );
  //////////////////////////////////////////////////////////////////////////////
  static ThemeData getDarkModeTheme() => ThemeData(
    fontFamily: FontFamily.ibmPlexSans,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: ColorScheme.dark(
      primary: Color(0xff4BB749),
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSecondaryFixed: Color(0xffFCE041),
      error: Colors.red,
      secondary: Color(0xffEAD800),
      inversePrimary: Color(0xffB8B8B8),
      inverseSurface: Color(0xff01CE21),
      onInverseSurface: Colors.orange,
      errorContainer: Color(0xffE7000B),
      onSecondaryContainer: Color(0xffFD9A00),
      tertiary: Color(0xffB7E2B6),
      onPrimaryContainer: Color(0xffF5F5F5),
      onPrimaryFixed: Color(0xff404040),
      onSurface: Color(0xffA1A1A1),
      onTertiary: Color(0xffE9C600),
      onTertiaryFixed: Color(0xff030303),
    ),
  );
}
