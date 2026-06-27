import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/theme/app_themes.dart';
import 'package:nowdelivery_user_app/view/theme/theme_manager.dart';

import 'common/localization/local_controller.dart';
import 'common/route/app_routes.dart';
import 'common/route/router.dart';

class NowUserApp extends StatelessWidget {
  const NowUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('current locale = ${context.locale.languageCode}');
    return MaterialApp(
      title: LangKeys.appNameKey.tr(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      debugShowCheckedModeBanner: false,
      darkTheme: AppThemes.getDarkModeTheme(),
      // locale: ref.watch(localeProvider),
      locale: context.locale,
      builder: DevicePreview.appBuilder,
      theme: AppThemes.getLightModeTheme(),
      themeMode: ThemeManager.appThemeMode,
      onGenerateRoute: AppRouter.onGenerate,
      initialRoute: AppRoutes.topBrandsScreen,
    );
  }
}