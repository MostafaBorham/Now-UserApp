import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/screens/home/home_screen.dart';
import 'package:nowdelivery_user_app/view/screens/onboarding/on_boarding_screen.dart';
import 'package:nowdelivery_user_app/view/screens/order/my_order_screen.dart';
import 'package:nowdelivery_user_app/view/screens/order/order_details_screen.dart';

import '../../view/screens/splash/splash_screen.dart';
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
      case AppRoutes.myOrderScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) =>  const MyOrderScreen());
    ////////////////////////////////////////////////////////////////
      case AppRoutes.orderDetailsScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) =>  const OrderDetailsScreen());
    ////////////////////////////////////////////////////////////////
      default:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const SizedBox.shrink());
    }
  }
}
