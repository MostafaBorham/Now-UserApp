import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/common/localization/constants.dart';
import 'package:nowdelivery_user_app/data/datasources/local/cache/shared_pref_manager.dart';

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
