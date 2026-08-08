import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:nowdelivery_user_app/features/main/presentation/screens/main_screen.dart';
import 'package:nowdelivery_user_app/features/welcome/data/datasources/local/cache/welcome_cache_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/presentation/screens/address_details_screen.dart';
import 'package:nowdelivery_user_app/features/address/presentation/screens/address_search_screen.dart';
import 'package:nowdelivery_user_app/features/address/presentation/screens/map_screen.dart';
import 'package:nowdelivery_user_app/features/address/presentation/screens/my_address_screen.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/screens/categories_screen.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/screens/category_details_screen.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:nowdelivery_user_app/features/discount/discount_code_screen.dart';
import 'package:nowdelivery_user_app/features/settings/presentation/screens/faq_screen.dart';
import 'package:nowdelivery_user_app/features/settings/presentation/screens/privacy_screen.dart';
import 'package:nowdelivery_user_app/features/settings/presentation/screens/edit_information_screen.dart';
import 'package:nowdelivery_user_app/features/support_chat/support_screen.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/screens/favourites_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/most_popular_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/offers_cannot_wait_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/top_brands_screen.dart';
import 'package:nowdelivery_user_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
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

  static FutureOr<String?> _redirectToLogin(
    BuildContext context,
    GoRouterState state,
  ) {
    final Map<String, dynamic> tokenData = WelcomeCacheService().getToken();
    final bool isGuest = tokenData[CacheKeys.isGuest] as bool? ?? true;

    return isGuest ? '/${AppRoutes.phoneVerificationScreen}' : null;
  }

  /// Wraps every routed screen so the OS/system back affordance (Android
  /// hardware button, iOS edge-swipe, predictive back) is swallowed on any
  /// screen that has something to pop. In-app back is left solely to each
  /// screen's circular app-bar button, which pops via [GoRouter.pop] — a forced
  /// navigator pop that [PopScope] does not block.
  ///
  /// Root screens (nothing below them in the stack, e.g. splash / onboarding /
  /// main) keep the default behaviour so the hardware back still exits the app
  /// instead of trapping the user on a screen with no back button.
  static Widget _blockSystemBack(BuildContext context, Widget child) =>
      PopScope(canPop: !context.canPop(), child: child);

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const SizedBox.shrink(),
    routes: <RouteBase>[
      GoRoute(
        name: AppRoutes.splashScreen,
        path: '/',
        builder: (context, state) =>
            _blockSystemBack(context, const SplashScreen()),
      ),
      GoRoute(
        name: AppRoutes.onBoardingScreen,
        path: '/${AppRoutes.onBoardingScreen}',
        redirect: (context, state) {
          bool hasToken;
          final Map<String, dynamic> tokenData = WelcomeCacheService()
              .getToken();
          final String token = tokenData[CacheKeys.tokenValue] as String? ?? '';
          hasToken = token.isNotEmpty;

          return hasToken ? '/${AppRoutes.mainScreen}' : null;
        },
        builder: (context, state) =>
            _blockSystemBack(context, const OnBoardingScreen()),
      ),
      GoRoute(
        name: AppRoutes.cartScreen,
        path: '/${AppRoutes.cartScreen}',
        builder: (context, state) =>
            _blockSystemBack(context, const CartScreen()),
      ),
      GoRoute(
        name: AppRoutes.mainScreen,
        path: '/${AppRoutes.mainScreen}',
        builder: (context, state) =>
            _blockSystemBack(context, const MainScreen()),
      ),
      GoRoute(
        name: AppRoutes.orderDetailsScreen,
        path: '/${AppRoutes.orderDetailsScreen}',
        builder: (context, state) =>
            _blockSystemBack(context, const OrderDetailsScreen()),
      ),
      GoRoute(
        name: AppRoutes.categoriesScreen,
        path: '/${AppRoutes.categoriesScreen}',
        builder: (context, state) =>
            _blockSystemBack(context, const CategoriesScreen()),
      ),
      GoRoute(
        name: AppRoutes.categoryDetailsScreen,
        path: '/${AppRoutes.categoryDetailsScreen}',
        builder: (context, state) {
          final category = state.extra as CategoryModel;

          return _blockSystemBack(
            context,
            CategoryDetailsScreen(category: category),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.favouritesScreen,
        path: '/${AppRoutes.favouritesScreen}',
        builder: (context, state) =>
            _blockSystemBack(context, const FavouritesScreen()),
      ),
      GoRoute(
        name: AppRoutes.walletScreen,
        path: '/${AppRoutes.walletScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) =>
            _blockSystemBack(context, const WalletScreen()),
      ),
      GoRoute(
        name: AppRoutes.fileComplaintScreen,
        path: '/${AppRoutes.fileComplaintScreen}',
        builder: (context, state) =>
            _blockSystemBack(context, const FileComplaintScreen()),
      ),
      GoRoute(
        name: AppRoutes.topBrandsScreen,
        path: '/${AppRoutes.topBrandsScreen}',
        builder: (context, state) =>
            _blockSystemBack(context, const TopBrandsScreen()),
      ),
      GoRoute(
        name: AppRoutes.mostPopularScreen,
        path: '/${AppRoutes.mostPopularScreen}',
        builder: (context, state) =>
            _blockSystemBack(context, const MostPopularScreen()),
      ),
      GoRoute(
        name: AppRoutes.offersCannotWaitScreen,
        path: '/${AppRoutes.offersCannotWaitScreen}',
        builder: (context, state) =>
            _blockSystemBack(context, const OffersCannotWaitScreen()),
      ),
      GoRoute(
        name: AppRoutes.notificationsScreen,
        path: '/${AppRoutes.notificationsScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) =>
            _blockSystemBack(context, const NotificationsScreen()),
      ),
      GoRoute(
        name: AppRoutes.searchScreen,
        path: '/${AppRoutes.searchScreen}',
        builder: (context, state) =>
            _blockSystemBack(context, const SearchScreen()),
      ),
      GoRoute(
        name: AppRoutes.allStoresScreen,
        path: '/${AppRoutes.allStoresScreen}',
        builder: (context, state) =>
            _blockSystemBack(context, const AllStoresScreen()),
      ),
      GoRoute(
        name: AppRoutes.viewStoreCategoryProductsScreen,
        path: '/${AppRoutes.viewStoreCategoryProductsScreen}',
        builder: (context, state) {
          final args = state.extra as ({int storeId, CategoryModel category})?;

          return _blockSystemBack(
            context,
            ViewStoreCategoryProductsScreen(
              storeId: args?.storeId ?? 0,
              category: args?.category ?? const CategoryModel(),
            ),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.storeDetailsScreen,
        path: '/${AppRoutes.storeDetailsScreen}',
        builder: (context, state) {
          final storeId = state.extra as int?;

          return _blockSystemBack(
            context,
            StoreDetailsScreen(storeId: storeId ?? 0),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.productDetailsScreen,
        path: '/${AppRoutes.productDetailsScreen}',
        builder: (context, state) {
          final productSlug = state.extra as String?;

          return _blockSystemBack(
            context,
            ProductDetailsScreen(productSlug: productSlug ?? ''),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.addPaymentCard,
        path: '/${AppRoutes.addPaymentCard}',
        builder: (context, state) =>
            _blockSystemBack(context, const AddPaymentCardScreen()),
      ),
      GoRoute(
        name: AppRoutes.paymentMethodsScreen,
        path: '/${AppRoutes.paymentMethodsScreen}',
        builder: (context, state) =>
            _blockSystemBack(context, const PaymentMethodsScreen()),
      ),
      GoRoute(
        name: AppRoutes.phoneVerificationScreen,
        path: '/${AppRoutes.phoneVerificationScreen}',
        redirect: _redirectLoggedInUserToMain,
        builder: (context, state) =>
            _blockSystemBack(context, const PhoneVerificationScreen()),
      ),
      GoRoute(
        name: AppRoutes.otpVerificationScreen,
        path: '/${AppRoutes.otpVerificationScreen}',
        redirect: _redirectLoggedInUserToMain,
        builder: (context, state) {
          final phoneNumber = state.extra as String?;

          return _blockSystemBack(
            context,
            OtpVerificationScreen(phoneNumber: phoneNumber ?? ''),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.personalInformationScreen,
        path: '/${AppRoutes.personalInformationScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) =>
            _blockSystemBack(context, const PersonalInformationScreen()),
      ),
      GoRoute(
        name: AppRoutes.orderConfirmedScreen,
        path: '/${AppRoutes.orderConfirmedScreen}',
        builder: (context, state) => _blockSystemBack(
          context,
          OrderConfirmedScreen(
            orders: state.extra as List<OrderModel>? ?? const <OrderModel>[],
          ),
        ),
      ),
      GoRoute(
        name: AppRoutes.trackOrderScreen,
        path: '/${AppRoutes.trackOrderScreen}',
        builder: (context, state) =>
            _blockSystemBack(context, const TrackOrderScreen()),
      ),
      GoRoute(
        name: AppRoutes.paymentFailedScreen,
        path: '/${AppRoutes.paymentFailedScreen}',
        builder: (context, state) =>
            _blockSystemBack(context, const PaymentFailedScreen()),
      ),
      GoRoute(
        name: AppRoutes.checkoutScreen,
        path: '/${AppRoutes.checkoutScreen}',
        // Checkout is only for authenticated users. A guest session
        // (isGuest == true) or no session at all is rerouted to phone
        // verification to log in; a registered user continues to checkout.
        redirect: _redirectToLogin,
        builder: (context, state) => _blockSystemBack(
          context,
          CheckoutScreen(storeId: state.extra as int?),
        ),
      ),
      GoRoute(
        name: AppRoutes.myAddressScreen,
        path: '/${AppRoutes.myAddressScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) =>
            _blockSystemBack(context, const MyAddressScreen()),
      ),
      GoRoute(
        name: AppRoutes.addressDetailsScreen,
        path: '/${AppRoutes.addressDetailsScreen}',
        builder: (context, state) {
          // Opened either from the address list (extra is the AddressModel —
          // editing an existing address) or from the map (extra is a record
          // carrying the fromMap flag, so the "Change" action can pop back to
          // the map still in the stack — creating a new address).
          final Object? extra = state.extra;
          if (extra is ({AddressModel address, bool fromMap})) {
            return _blockSystemBack(
              context,
              AddressDetailsScreen(
                address: extra.address,
                cameFromMap: extra.fromMap,
              ),
            );
          }
          return _blockSystemBack(
            context,
            AddressDetailsScreen(
              address: extra as AddressModel,
              isEditScreen: true,
            ),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.addNewAddressFromMapScreen,
        path: '/${AppRoutes.addNewAddressFromMapScreen}',
        builder: (context, state) {
          final currentLocation = state.extra as LatLng?;
          return _blockSystemBack(
            context,
            AddNewAddressFromMap(currentLocation: currentLocation),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.addressSearchScreen,
        path: '/${AppRoutes.addressSearchScreen}',
        builder: (context, state) => _blockSystemBack(
          context,
          AddressSearchScreen(currentLocation: state.extra as LatLng?),
        ),
      ),
      GoRoute(
        name: AppRoutes.discountCodeScreen,
        path: '/${AppRoutes.discountCodeScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) =>
            _blockSystemBack(context, const DiscountCodeScreen()),
      ),
      GoRoute(
        name: AppRoutes.supportScreen,
        path: '/${AppRoutes.supportScreen}',
        redirect: _redirectToLogin,
        builder: (context, state) =>
            _blockSystemBack(context, const SupportScreen()),
      ),
      GoRoute(
        name: AppRoutes.faqScreen,
        path: '/${AppRoutes.faqScreen}',
        builder: (context, state) => _blockSystemBack(context, const FaqScreen()),
      ),
      GoRoute(
        name: AppRoutes.privacyPolicyScreen,
        path: '/${AppRoutes.privacyPolicyScreen}',
        builder: (context, state) =>
            _blockSystemBack(context, const PrivacyPolicyScreen()),
      ),
      GoRoute(
        name: AppRoutes.editInformationScreen,
        path: '/${AppRoutes.editInformationScreen}',
        builder: (context, state) =>
            _blockSystemBack(context, const EditInformationScreen()),
      ),
    ],
  );
}
