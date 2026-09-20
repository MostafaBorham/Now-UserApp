import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast_route_observer.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/presentation/screens/address_details_screen.dart';
import 'package:nowdelivery_user_app/features/address/presentation/screens/address_search_screen.dart';
import 'package:nowdelivery_user_app/features/address/presentation/screens/map_screen.dart';
import 'package:nowdelivery_user_app/features/address/presentation/screens/my_address_screen.dart';
import 'package:nowdelivery_user_app/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:nowdelivery_user_app/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:nowdelivery_user_app/features/auth/presentation/screens/phone_verification_screen.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/screens/categories_screen.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/screens/category_details_screen.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/screens/favourites_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/most_popular_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/offers_cannot_wait_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/top_brands_screen.dart';
import 'package:nowdelivery_user_app/features/main/presentation/screens/main_screen.dart';
import 'package:nowdelivery_user_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/screens/order_details_screen.dart';
import 'package:nowdelivery_user_app/features/payment_methods/presentation/add_payment_card_screen.dart';
import 'package:nowdelivery_user_app/features/payment_methods/presentation/payment_methods_screen.dart';
import 'package:nowdelivery_user_app/features/personal_information/presentation/screens/edit_information_screen.dart';
import 'package:nowdelivery_user_app/features/personal_information/presentation/screens/personal_information_screen.dart';
import 'package:nowdelivery_user_app/features/products/presentation/screens/product_details_screen.dart';
import 'package:nowdelivery_user_app/features/promotion/presentation/screens/discount_code_screen.dart';
import 'package:nowdelivery_user_app/features/search/presentation/screens/search_screen.dart';
import 'package:nowdelivery_user_app/features/settings/presentation/screens/faq_screen.dart';
import 'package:nowdelivery_user_app/features/support/presentation/screens/support_faqs_screen.dart';
import 'package:nowdelivery_user_app/features/settings/presentation/screens/privacy_screen.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/screens/all_stores_screen.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/screens/store_details_screen.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/screens/view_store_category_products_screen.dart';
import 'package:nowdelivery_user_app/features/support/presentation/screens/file_complaint_screen.dart';
import 'package:nowdelivery_user_app/features/support_chat/support_screen.dart';
import 'package:nowdelivery_user_app/features/tracking_order/presentation/screens/order_confirmed_screen.dart';
import 'package:nowdelivery_user_app/features/tracking_order/presentation/screens/payment_failed_screen.dart';
import 'package:nowdelivery_user_app/features/tracking_order/presentation/screens/track_order_screen.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:nowdelivery_user_app/features/welcome/presentation/screens/on_boarding_screen.dart';
import 'package:nowdelivery_user_app/features/welcome/presentation/screens/splash_screen.dart';

import 'app_routes.dart';

abstract class AppRouter {
  /// Shared redirect of the verification flow (phone + OTP screens).
  ///
  /// Those screens exist only to log a guest in, so once an access token is
  /// cached (a logged-in user) they redirect to the main screen. A guest
  /// session stores only a guest token, and guests are exactly who these
  /// screens are for.
  static String? _redirectLoggedInUserToMain(
    BuildContext context,
    GoRouterState state,
  ) {
    return TokenCacheService().hasAccessToken
        ? '/${AppRoutes.mainScreen}'
        : null;
  }

  static FutureOr<String?> _redirectToLogin(
    BuildContext context,
    GoRouterState state,
  ) {
    return TokenCacheService().hasAccessToken
        ? null
        : '/${AppRoutes.phoneVerificationScreen}';
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    observers: <NavigatorObserver>[AppToastRouteObserver()],
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
          // Onboarding is only for a brand-new install with no session yet.
          // Once any token exists — a guest token or a logged-in user's access
          // token — skip straight to the main screen.
          final TokenCacheService tokenCache = TokenCacheService();
          final bool hasToken =
              tokenCache.hasAccessToken || tokenCache.hasGuestToken;

          return hasToken ? '/${AppRoutes.mainScreen}' : null;
        },
        builder: (context, state) => const OnBoardingScreen(),
      ),
      GoRoute(
        name: AppRoutes.cartScreen,
        path: '/${AppRoutes.cartScreen}',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        name: AppRoutes.mainScreen,
        path: '/${AppRoutes.mainScreen}',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        name: AppRoutes.orderDetailsScreen,
        path: '/${AppRoutes.orderDetailsScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) =>
            OrderDetailsScreen(orderUuid: state.extra as String),
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

          return CategoryDetailsScreen(category: category);
        },
      ),
      GoRoute(
        name: AppRoutes.favouritesScreen,
        path: '/${AppRoutes.favouritesScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) => const FavouritesScreen(),
      ),
      GoRoute(
        name: AppRoutes.walletScreen,
        path: '/${AppRoutes.walletScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        name: AppRoutes.fileComplaintScreen,
        path: '/${AppRoutes.fileComplaintScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) =>
            FileComplaintScreen(order: state.extra as OrderModel),
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
          final category = state.extra as CategoryModel?;

          return ViewStoreCategoryProductsScreen(
            category: category ?? const CategoryModel(),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.storeDetailsScreen,
        // The id is identity, so it lives in the path, not in `extra`.
        // go_router serializes `extra` through JSON whenever it re-parses the
        // route — a rebuilt Router (hot reload, DevTools "Select Widget Mode",
        // state restoration) — and silently drops anything JSON cannot encode,
        // which a record is. The id then arrived null and the screen requested
        // `/stores/0`. A path parameter is part of the URL and survives all of
        // it. `extra` now carries only the name, a plain map JSON can encode.
        path: '/${AppRoutes.storeDetailsScreen}/:id',
        builder: (context, state) {
          // No `?? 0` fallback: 0 is a well-formed id the API answers with a
          // 404, so an unparseable segment must not become a real request.
          return StoreDetailsScreen(
            storeId: int.tryParse(state.pathParameters['id'] ?? ''),
            storeName: state.extra as Map<String, dynamic>?,
          );
        },
      ),
      GoRoute(
        name: AppRoutes.productDetailsScreen,
        path: '/${AppRoutes.productDetailsScreen}',
        builder: (context, state) {
          final productSlug = state.extra as String?;

          return ProductDetailsScreen(productSlug: productSlug ?? '');
        },
      ),
      GoRoute(
        name: AppRoutes.addPaymentCard,
        path: '/${AppRoutes.addPaymentCard}',
        redirect: _redirectToLogin,
        builder: (context, state) => const AddPaymentCardScreen(),
      ),
      GoRoute(
        name: AppRoutes.paymentMethodsScreen,
        path: '/${AppRoutes.paymentMethodsScreen}',
        redirect: _redirectToLogin,
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

          return OtpVerificationScreen(phoneNumber: phoneNumber ?? '');
        },
      ),
      GoRoute(
        name: AppRoutes.personalInformationScreen,
        path: '/${AppRoutes.personalInformationScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) => const PersonalInformationScreen(),
      ),
      GoRoute(
        name: AppRoutes.completeProfileScreen,
        path: '/${AppRoutes.completeProfileScreen}',
        // Login-gated like any user screen, but deliberately *not*
        // `_redirectLoggedInUserToMain`: having a token is exactly the state
        // this screen is for.
        redirect: _redirectToLogin,
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        name: AppRoutes.orderConfirmedScreen,
        path: '/${AppRoutes.orderConfirmedScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) => OrderConfirmedScreen(
          orders: state.extra as List<OrderModel>? ?? const <OrderModel>[],
        ),
      ),
      GoRoute(
        name: AppRoutes.trackOrderScreen,
        path: '/${AppRoutes.trackOrderScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) =>
            TrackOrderScreen(orderUuid: state.extra as String? ?? ''),
      ),
      GoRoute(
        name: AppRoutes.paymentFailedScreen,
        path: '/${AppRoutes.paymentFailedScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) => const PaymentFailedScreen(),
      ),
      GoRoute(
        name: AppRoutes.checkoutScreen,
        path: '/${AppRoutes.checkoutScreen}',
        // Checkout is only for authenticated users. A guest session
        // (isGuest == true) or no session at all is rerouted to phone
        // verification to log in; a registered user continues to checkout.
        redirect: _redirectToLogin,
        builder: (context, state) =>
            CheckoutScreen(storeId: state.extra as int?),
      ),
      GoRoute(
        name: AppRoutes.myAddressScreen,
        path: '/${AppRoutes.myAddressScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) => const MyAddressScreen(),
      ),
      GoRoute(
        name: AppRoutes.addressDetailsScreen,
        path: '/${AppRoutes.addressDetailsScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) {
          // Opened either from the address list (extra is the AddressModel —
          // editing an existing address) or from the map (extra is a record
          // carrying the fromMap flag, so the "Change" action can pop back to
          // the map still in the stack). Coming from the map covers both
          // creating a new address and relocating an existing one, which is
          // what isEdit distinguishes.
          final Object? extra = state.extra;
          if (extra is ({AddressModel address, bool fromMap, bool isEdit})) {
            return AddressDetailsScreen(
              address: extra.address,
              cameFromMap: extra.fromMap,
              isEditScreen: extra.isEdit,
            );
          }
          return AddressDetailsScreen(
            address: extra as AddressModel,
            isEditScreen: true,
          );
        },
      ),
      GoRoute(
        name: AppRoutes.addNewAddressFromMapScreen,
        path: '/${AppRoutes.addNewAddressFromMapScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) {
          // Non-null only when changing an existing address's location.
          final address = state.extra as AddressModel?;
          return AddNewAddressFromMap(address: address);
        },
      ),
      GoRoute(
        name: AppRoutes.addressSearchScreen,
        path: '/${AppRoutes.addressSearchScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) {
          final extra =
              state.extra as ({LatLng? bias, bool isChangingAddress})?;
          return AddressSearchScreen(
            currentLocation: extra?.bias,
            isChangingAddress: extra?.isChangingAddress ?? false,
          );
        },
      ),
      GoRoute(
        name: AppRoutes.discountCodeScreen,
        path: '/${AppRoutes.discountCodeScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) => const DiscountCodeScreen(),
      ),
      GoRoute(
        name: AppRoutes.supportScreen,
        path: '/${AppRoutes.supportScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        name: AppRoutes.faqScreen,
        path: '/${AppRoutes.faqScreen}',
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        name: AppRoutes.supportFaqsScreen,
        path: '/${AppRoutes.supportFaqsScreen}',
        builder: (context, state) => const SupportFaqsScreen(),
      ),
      GoRoute(
        name: AppRoutes.privacyPolicyScreen,
        path: '/${AppRoutes.privacyPolicyScreen}',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        name: AppRoutes.editInformationScreen,
        path: '/${AppRoutes.editInformationScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) => const EditInformationScreen(),
      ),
    ],
  );
}
