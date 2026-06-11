import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/theme/app_themes.dart';
import 'package:nowdelivery_user_app/view/theme/theme_manager.dart';

import 'common/route/app_routes.dart';
import 'common/route/router.dart';

class NowUserApp extends StatelessWidget {
  const NowUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: LangKeys.appNameKey.tr(),
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      debugShowCheckedModeBanner: false,
      darkTheme: AppThemes.getDarkModeTheme(),
      theme: AppThemes.getLightModeTheme(),
      themeMode: ThemeManager.appThemeMode,
      onGenerateRoute: AppRouter.onGenerate,
      initialRoute: AppRoutes.splashScreen,
    );
  }
}
