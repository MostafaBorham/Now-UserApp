import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/categories/categories_interface.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:nowdelivery_user_app/features/favourites/favourites_interface.dart';
import 'package:nowdelivery_user_app/features/home/home_interface.dart';
import 'package:nowdelivery_user_app/features/notifications/notifications_interface.dart';
import 'package:nowdelivery_user_app/features/orders/orders_interface.dart';
import 'package:nowdelivery_user_app/features/products/presentation/screens/product_details_screen.dart';
import 'package:nowdelivery_user_app/features/guest_verification/guest_verification_interface.dart';
import 'package:nowdelivery_user_app/features/payment_methods/payment_methods_interface.dart';
import 'package:nowdelivery_user_app/features/search/search_interface.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/screens/all_stores_screen.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/screens/store_details_screen.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/screens/view_store_category_products_screen.dart';
import 'package:nowdelivery_user_app/features/support/support_interface.dart';
import 'package:nowdelivery_user_app/features/wallet/wallet_interface.dart';
import 'package:nowdelivery_user_app/features/welcome/welcome_interface.dart';

import 'app_routes.dart';

abstract class AppRouter {
  static Route<dynamic> onGenerate(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splashScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.onBoardingScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) =>  const OnBoardingScreen());
      ////////////////////////////////////////////////////////////////
      case AppRoutes.mainScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.orderDetailsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OrderDetailsScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.categoriesScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CategoriesScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.categoryDetailsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CategoryDetailsScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.favouritesScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const FavouritesScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.walletScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const WalletScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.fileComplaintScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const FileComplaintScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.topBrandsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TopBrandsScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.mostPopularScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MostPopularScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.offersCannotWaitScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OffersCannotWaitScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.notificationsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NotificationsScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.searchScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SearchScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.allStoresScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AllStoresScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.viewStoreCategoryProductsScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ViewStoreCategoryProductsScreen());
    ////////////////////////////////////////////////////////////////
      case AppRoutes.storeDetailsScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const StoreDetailsScreen());
    ////////////////////////////////////////////////////////////////
      case AppRoutes.productDetailsScreen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ProductDetailsScreen());

      case AppRoutes.addPaymentCard:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddPaymentCardScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.paymentMethodsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PaymentMethodsScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.phoneVerificationScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PhoneVerificationScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.otpVerificationScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OtpVerificationScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.personalInformationScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PersonalInformationScreen(),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SizedBox.shrink(),
        );
    }
  }
}
