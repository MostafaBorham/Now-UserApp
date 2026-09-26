import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/formatters/date_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/constants.dart';

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

  String getLocalizedNumericApiDateTime({String? apiDateTimeStamp}){
    return formatLocalizedNumericDateTime(this, apiDateTimeStamp);
  }
}
