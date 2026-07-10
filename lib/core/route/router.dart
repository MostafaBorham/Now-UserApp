import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/address/address_details_screen.dart';
import 'package:nowdelivery_user_app/features/address/map.dart';
import 'package:nowdelivery_user_app/features/address/my_address_screen.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/screens/categories_screen.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/screens/category_details_screen.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:nowdelivery_user_app/features/discount/discount_code_screen.dart';
import 'package:nowdelivery_user_app/features/faq/faq_screen.dart';
import 'package:nowdelivery_user_app/features/privacy/privacy_screen.dart';
import 'package:nowdelivery_user_app/features/settings/edit_information_screen.dart';
import 'package:nowdelivery_user_app/features/support_chat/support_screen.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/screens/favourites_screen.dart';
import 'package:nowdelivery_user_app/core/presentation/screens/main_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/most_popular_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/offers_cannot_wait_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/top_brands_screen.dart';
import 'package:nowdelivery_user_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/screens/order_details_screen.dart';
import 'package:nowdelivery_user_app/features/products/presentation/screens/product_details_screen.dart';
import 'package:nowdelivery_user_app/features/guest_verification/presentation/screens/otp_verification_screen.dart';
import 'package:nowdelivery_user_app/features/guest_verification/presentation/screens/personal_information_screen.dart';
import 'package:nowdelivery_user_app/features/guest_verification/presentation/screens/phone_verification_screen.dart';
import 'package:nowdelivery_user_app/features/payment_methods/presentation/add_payment_card_screen.dart';
import 'package:nowdelivery_user_app/features/payment_methods/presentation/payment_methods_screen.dart';
import 'package:nowdelivery_user_app/features/search/presentation/screens/search_screen.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/screens/all_stores_screen.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/screens/store_details_screen.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/screens/view_store_category_products_screen.dart';
import 'package:nowdelivery_user_app/features/support/presentation/screens/file_complaint_screen.dart';
import 'package:nowdelivery_user_app/features/tracking_order/presentation/screens/order_confirmed_screen.dart';
import 'package:nowdelivery_user_app/features/tracking_order/presentation/screens/track_order_screen.dart';
import 'package:nowdelivery_user_app/features/tracking_order/presentation/screens/payment_failed_screen.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:nowdelivery_user_app/features/welcome/presentation/screens/on_boarding_screen.dart';
import 'package:nowdelivery_user_app/features/welcome/presentation/screens/splash_screen.dart';

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
      ////////////////////////////////////////////////////////////////
      case AppRoutes.orderConfirmedScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OrderConfirmedScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.trackOrderScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TrackOrderScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.paymentFailedScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PaymentFailedScreen(),
        );
        ///////////////////////////////////////////////////
      case AppRoutes.checkoutScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CheckoutScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.myAddressScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MyAddressScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.addressDetailsScreen:
        final isEditing = settings.arguments as bool? ?? false;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AddressDetailsScreen(isEditing: isEditing),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.addNewAddressFromMapScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddNewAddressFromMap(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.discountCodeScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DiscountCodeScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.supportScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SupportScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.faqScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const FaqScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.privacyPolicyScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PrivacyPolicyScreen(),
        );
      ////////////////////////////////////////////////////////////////
      case AppRoutes.editInformationScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const EditInformationScreen(),
        );
    ///////////////////////////////////////////////////
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SizedBox.shrink(),
        );
    }
  }
}
