import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class LocalizationInit extends StatelessWidget {
  const LocalizationInit({super.key, required this.child});

  final Widget child;
  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
        supportedLocales: LocalizationConstants.supportedLocales,
        path: LocalizationConstants.languagesPath,
        startLocale: LocalizationConstants.arabicLocale,
        fallbackLocale: LocalizationConstants.englishLocale,
        saveLocale: true,
        useOnlyLangCode: false,
        child: child);
  }
}