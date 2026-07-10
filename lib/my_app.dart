import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_themes.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/theme_manager.dart';
import 'package:nowdelivery_user_app/core/routing/app_router.dart';

class NowUserApp extends StatelessWidget {
  const NowUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: LangKeys.appNameKey.tr(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      debugShowCheckedModeBanner: false,
      darkTheme: AppThemes.getDarkModeTheme(),
      locale: context.locale,
      builder: DevicePreview.appBuilder,
      theme: AppThemes.getLightModeTheme(),
      themeMode: ThemeManager.appThemeMode,
      routerConfig: AppRouter.router,
    );
  }
}
