import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/formatters/date_formatter.dart';
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

  String getLocalizedApiText(Map<String, dynamic>? translations) {
    if (translations == null) return '';
    final Object? value = isRTL
        ? translations[LocalizationConstants.arabicLangCode] ??
              translations[LocalizationConstants.englishLangCode]
        : translations[LocalizationConstants.englishLangCode] ??
              translations[LocalizationConstants.arabicLangCode];
    return value?.toString() ?? '';
  }

  String getLocalizedApiDate({String? apiDateTimeStamp}){
    return formatLocalizedDate(this, apiDateTimeStamp);
  }

  String getLocalizedNumericApiDate({String? apiDateTimeStamp}){
    return formatLocalizedNumericDate(this, apiDateTimeStamp);
  }
}