import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/screens/category_details_screen.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/screens/favourites_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/main_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/most_popular_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/offers_cannot_wait_screen.dart';
import 'package:nowdelivery_user_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:nowdelivery_user_app/features/welcome/presentation/screens/on_boarding_screen.dart';
import 'package:nowdelivery_user_app/features/support/presentation/screens/file_complaint_screen.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/screens/order_details_screen.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/screens/categories_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/top_brands_screen.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/screens/wallet_screen.dart';

import '../../features/welcome/presentation/screens/splash_screen.dart';
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
      case AppRoutes.mainLayoutScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) =>  const MainScreen());
    ////////////////////////////////////////////////////////////////
      case AppRoutes.orderDetailsScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) =>  const OrderDetailsScreen());
    ////////////////////////////////////////////////////////////////
      case AppRoutes.categoriesScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const CategoriesScreen());
    ////////////////////////////////////////////////////////////////
      case AppRoutes.categoryDetailsScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const CategoryDetailsScreen());
    ////////////////////////////////////////////////////////////////
      case AppRoutes.favouritesScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const FavouritesScreen());
    ////////////////////////////////////////////////////////////////
      case AppRoutes.walletScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const WalletScreen());
    ////////////////////////////////////////////////////////////////
      case AppRoutes.fileComplaintScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const FileComplaintScreen());
    ////////////////////////////////////////////////////////////////
      case AppRoutes.topBrandsScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const TopBrandsScreen());
    ////////////////////////////////////////////////////////////////
      case AppRoutes.mostPopularScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const MostPopularScreen());
    ////////////////////////////////////////////////////////////////
      case AppRoutes.offersCannotWaitScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const OffersCannotWaitScreen());
    ////////////////////////////////////////////////////////////////
      case AppRoutes.notificationsScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const NotificationsScreen());
      default:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const SizedBox.shrink());
    }
  }
}
