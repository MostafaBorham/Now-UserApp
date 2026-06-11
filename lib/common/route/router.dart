import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/screens/home_screen.dart';
import 'package:nowdelivery_user_app/view/screens/on_boarding_screen.dart';

import '../../view/screens/splash_screen.dart';
import 'app_routes.dart';

abstract class AppRouter {
  static Route<dynamic> onGenerate(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splashScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const SplashScreen());
    ////////////////////////////////////////////////////////////////
      case AppRoutes.onBoardingScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) =>  const OnBoardingScreen());
    ////////////////////////////////////////////////////////////////
      case AppRoutes.homeScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) =>  const HomeScreen());
    ////////////////////////////////////////////////////////////////
      default:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const SizedBox.shrink());
    }
  }
}
