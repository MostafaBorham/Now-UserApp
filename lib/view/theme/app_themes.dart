import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/assets/fonts.gen.dart';

abstract class AppThemes {
  static ThemeData getLightModeTheme() => ThemeData(
    fontFamily: FontFamily.roboto,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: Color(0xff4BB749),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      error: Colors.red,
      secondary: Color(0xffEAD800),
      inversePrimary: Color(0xffB8B8B8)
    ),
  );
  //////////////////////////////////////////////////////////////////////////////
  static ThemeData getDarkModeTheme() => ThemeData(
    fontFamily: FontFamily.roboto,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: ColorScheme.dark(
      primary: Color(0xff4BB749),
      onPrimary: Colors.black,
        onSecondary: Colors.white,
      error: Colors.red,
      secondary: Color(0xffEAD800),
        inversePrimary: Color(0xffB8B8B8)
    ),
  );
}
