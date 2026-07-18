import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/features/welcome/data/datasources/local/cache/welcome_cache_service.dart';
import 'package:nowdelivery_user_app/features/address/address_details_screen.dart';
import 'package:nowdelivery_user_app/features/address/map.dart';
import 'package:nowdelivery_user_app/features/address/my_address_screen.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
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
import 'package:nowdelivery_user_app/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:nowdelivery_user_app/features/guest_verification/presentation/screens/personal_information_screen.dart';
import 'package:nowdelivery_user_app/features/auth/presentation/screens/phone_verification_screen.dart';
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
  /// Shared redirect of the verification flow (phone + OTP screens).
  ///
  /// Those screens exist only to log a guest in, so once a user token is
  /// cached (token present and `isGuest == false`) they redirect to the main
  /// screen. Checking the token alone is not enough — a guest session also
  /// stores a (guest) token, and guests are exactly who these screens are
  /// for.
  static String? _redirectLoggedInUserToMain(
    BuildContext context,
    GoRouterState state,
  ) {
    final Map<String, dynamic> tokenData = WelcomeCacheService().getToken();
    final String token = tokenData[CacheKeys.tokenValue] as String? ?? '';
    final bool isGuest = tokenData[CacheKeys.isGuest] as bool? ?? true;

    return token.isNotEmpty && !isGuest ? '/${AppRoutes.mainScreen}' : null;
  }

  static FutureOr<String?> _redirectToLogin(BuildContext context, GoRouterState state) {
    final Map<String, dynamic> tokenData =
    WelcomeCacheService().getToken();
    final bool isGuest = tokenData[CacheKeys.isGuest] as bool? ?? true;

    return isGuest ? '/${AppRoutes.phoneVerificationScreen}' : null;
  }
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const SizedBox.shrink(),
    routes: <RouteBase>[
      GoRoute(
        name: AppRoutes.splashScreen,
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: AppRoutes.onBoardingScreen,
        path: '/${AppRoutes.onBoardingScreen}',
        redirect: (context, state) {
          bool hasToken;
            final Map<String, dynamic> tokenData =
                WelcomeCacheService().getToken();
            final String token =
                tokenData[CacheKeys.tokenValue] as String? ?? '';
            hasToken = token.isNotEmpty;

          return hasToken ? '/${AppRoutes.mainScreen}' : null;
        },
        builder: (context, state) => const OnBoardingScreen(),
      ),
      GoRoute(
        name: AppRoutes.mainScreen,
        path: '/${AppRoutes.mainScreen}',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        name: AppRoutes.orderDetailsScreen,
        path: '/${AppRoutes.orderDetailsScreen}',
        builder: (context, state) => const OrderDetailsScreen(),
      ),
      GoRoute(
        name: AppRoutes.categoriesScreen,
        path: '/${AppRoutes.categoriesScreen}',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        name: AppRoutes.categoryDetailsScreen,
        path: '/${AppRoutes.categoryDetailsScreen}',
        builder: (context, state) {
          final category = state.extra as CategoryModel;

          return CategoryDetailsScreen(
            category: category,
          );
        },
      ),
      GoRoute(
        name: AppRoutes.favouritesScreen,
        path: '/${AppRoutes.favouritesScreen}',
        builder: (context, state) => const FavouritesScreen(),
      ),
      GoRoute(
        name: AppRoutes.walletScreen,
        path: '/${AppRoutes.walletScreen}',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        name: AppRoutes.fileComplaintScreen,
        path: '/${AppRoutes.fileComplaintScreen}',
        builder: (context, state) => const FileComplaintScreen(),
      ),
      GoRoute(
        name: AppRoutes.topBrandsScreen,
        path: '/${AppRoutes.topBrandsScreen}',
        builder: (context, state) => const TopBrandsScreen(),
      ),
      GoRoute(
        name: AppRoutes.mostPopularScreen,
        path: '/${AppRoutes.mostPopularScreen}',
        builder: (context, state) => const MostPopularScreen(),
      ),
      GoRoute(
        name: AppRoutes.offersCannotWaitScreen,
        path: '/${AppRoutes.offersCannotWaitScreen}',
        builder: (context, state) => const OffersCannotWaitScreen(),
      ),
      GoRoute(
        name: AppRoutes.notificationsScreen,
        path: '/${AppRoutes.notificationsScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        name: AppRoutes.searchScreen,
        path: '/${AppRoutes.searchScreen}',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        name: AppRoutes.allStoresScreen,
        path: '/${AppRoutes.allStoresScreen}',
        builder: (context, state) => const AllStoresScreen(),
      ),
      GoRoute(
        name: AppRoutes.viewStoreCategoryProductsScreen,
        path: '/${AppRoutes.viewStoreCategoryProductsScreen}',
        builder: (context, state) {
          final args =
              state.extra as ({int storeId, CategoryModel category})?;

          return ViewStoreCategoryProductsScreen(
            storeId: args?.storeId ?? 0,
            category: args?.category ?? const CategoryModel(),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.storeDetailsScreen,
        path: '/${AppRoutes.storeDetailsScreen}',
        builder: (context, state) {
          final storeId = state.extra as int?;

          return StoreDetailsScreen(
            storeId: storeId ?? 0,
          );
        },
      ),
      GoRoute(
        name: AppRoutes.productDetailsScreen,
        path: '/${AppRoutes.productDetailsScreen}',
          builder: (context, state) {
            final productSlug = state.extra as String?;

            return ProductDetailsScreen(
              productSlug: productSlug??'',
            );
          }
      ),
      GoRoute(
        name: AppRoutes.addPaymentCard,
        path: '/${AppRoutes.addPaymentCard}',
        builder: (context, state) => const AddPaymentCardScreen(),
      ),
      GoRoute(
        name: AppRoutes.paymentMethodsScreen,
        path: '/${AppRoutes.paymentMethodsScreen}',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        name: AppRoutes.phoneVerificationScreen,
        path: '/${AppRoutes.phoneVerificationScreen}',
        redirect: _redirectLoggedInUserToMain,
        builder: (context, state) => const PhoneVerificationScreen(),
      ),
      GoRoute(
        name: AppRoutes.otpVerificationScreen,
        path: '/${AppRoutes.otpVerificationScreen}',
        redirect: _redirectLoggedInUserToMain,
        builder: (context, state) {
          final phoneNumber = state.extra as String?;

          return OtpVerificationScreen(
            phoneNumber: phoneNumber ?? '',
          );
        },
      ),
      GoRoute(
        name: AppRoutes.personalInformationScreen,
        path: '/${AppRoutes.personalInformationScreen}',
        builder: (context, state) => const PersonalInformationScreen(),
      ),
      GoRoute(
        name: AppRoutes.orderConfirmedScreen,
        path: '/${AppRoutes.orderConfirmedScreen}',
        builder: (context, state) => const OrderConfirmedScreen(),
      ),
      GoRoute(
        name: AppRoutes.trackOrderScreen,
        path: '/${AppRoutes.trackOrderScreen}',
        builder: (context, state) => const TrackOrderScreen(),
      ),
      GoRoute(
        name: AppRoutes.paymentFailedScreen,
        path: '/${AppRoutes.paymentFailedScreen}',
        builder: (context, state) => const PaymentFailedScreen(),
      ),
      GoRoute(
        name: AppRoutes.checkoutScreen,
        path: '/${AppRoutes.checkoutScreen}',
        // Checkout is only for authenticated users. A guest session
        // (isGuest == true) or no session at all is rerouted to phone
        // verification to log in; a registered user continues to checkout.
        redirect: _redirectToLogin,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        name: AppRoutes.myAddressScreen,
        path: '/${AppRoutes.myAddressScreen}',
        builder: (context, state) => const MyAddressScreen(),
      ),
      GoRoute(
        name: AppRoutes.addressDetailsScreen,
        path: '/${AppRoutes.addressDetailsScreen}',
        builder: (context, state) {
          final isEditing = state.extra as bool? ?? false;
          return AddressDetailsScreen(isEditing: isEditing);
        },
      ),
      GoRoute(
        name: AppRoutes.addNewAddressFromMapScreen,
        path: '/${AppRoutes.addNewAddressFromMapScreen}',
        builder: (context, state) => const AddNewAddressFromMap(),
      ),
      GoRoute(
        name: AppRoutes.discountCodeScreen,
        path: '/${AppRoutes.discountCodeScreen}',
        builder: (context, state) => const DiscountCodeScreen(),
      ),
      GoRoute(
        name: AppRoutes.supportScreen,
        path: '/${AppRoutes.supportScreen}',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        name: AppRoutes.faqScreen,
        path: '/${AppRoutes.faqScreen}',
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        name: AppRoutes.privacyPolicyScreen,
        path: '/${AppRoutes.privacyPolicyScreen}',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        name: AppRoutes.editInformationScreen,
        path: '/${AppRoutes.editInformationScreen}',
        builder: (context, state) => const EditInformationScreen(),
      ),
    ],
  );
}
