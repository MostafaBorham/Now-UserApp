import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/screens/splash_screen.dart';
import 'package:nowdelivery_user_app/view/theme/app_themes.dart';
import 'package:nowdelivery_user_app/view/theme/theme_manager.dart';

import 'common/route/app_routes.dart';
import 'common/route/router.dart';

class NowUserApp extends StatelessWidget {
  const NowUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Now User App',
      debugShowCheckedModeBanner: false,
      darkTheme: AppThemes.getDarkModeTheme(),
      theme: AppThemes.getLightModeTheme(),
      themeMode: ThemeManager.appThemeMode,
      onGenerateRoute: AppRouter.onGenerate,
      initialRoute: AppRoutes.splashScreen,
    );
  }
}