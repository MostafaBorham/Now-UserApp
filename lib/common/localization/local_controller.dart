import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/common/localization/constants.dart';

class LocalController extends StateNotifier<Locale>{
  LocalController() : super(LocalizationConstants.englishLocale);

  void changeAppLocale(Locale locale){
    state = locale;
  }

  bool isArabic(){
    return state == LocalizationConstants.arabicLocale;
  }
}

final localeProvider =
StateNotifierProvider<LocalController, Locale>(
      (ref) => LocalController(),
);