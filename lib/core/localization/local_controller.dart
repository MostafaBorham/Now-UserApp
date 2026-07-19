import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/constants.dart';

class LocalController extends StateNotifier<Locale> {
  LocalController() : super(LocalizationConstants.englishLocale);

/*  static late Locale currentLocale;

  static Future getCurrentLocale() async {
    final currentCacheLanguage = await SharedPrefManager.getString(
      LocalizationConstants.langCacheKey,
    );
    if (currentCacheLanguage != null) {
      currentLocale = Locale(currentCacheLanguage);
    } else {
      final deviceLocale = PlatformDispatcher.instance.locale;
      if (deviceLocale == LocalizationConstants.arabicLocale) {
        currentLocale = deviceLocale;
      } else {
        currentLocale = LocalizationConstants.englishLocale;
      }
    }
  }*/
/*
  Future<void> changeAppLocale(Locale locale) async {
    await SharedPrefManager.saveString(
      LocalizationConstants.langCacheKey,
      locale.languageCode,
    ).then((_) {
      state = locale;
    });
  }*/

  bool isArabic() {
    return state == LocalizationConstants.arabicLocale;
  }
}

final localeProvider = StateNotifierProvider<LocalController, Locale>(
  (ref) => LocalController(),
);

extension LocaleExt on BuildContext{
  bool get isRTL => locale == LocalizationConstants.arabicLocale;

  /// Resolves an API text map like `{'en': '...', 'ar': '...'}` to the string
  /// for the current locale. Falls back to the other language when the current
  /// one is missing, and to an empty string when the map is null/empty — so
  /// callers can pass a nullable or partial map without extra guards.
  String getLocalizedApiText(Map<String, dynamic>? translations) {
    if (translations == null) return '';
    final Object? value = isRTL
        ? translations[LocalizationConstants.arabicLangCode] ??
              translations[LocalizationConstants.englishLangCode]
        : translations[LocalizationConstants.englishLangCode] ??
              translations[LocalizationConstants.arabicLangCode];
    return value?.toString() ?? '';
  }
}