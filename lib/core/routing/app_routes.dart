/// Route names & paths used by GoRouter.
///
/// `name` constants are used with `context.pushNamed` / `context.goNamed`;
/// `path` constants are the URL paths registered in [AppRouter].
abstract class AppRoutes {
  static const String splashScreen = 'splash';
  static const String noInternetScreen = 'no-internet';
  static const String onBoardingScreen = 'onboarding';
  static const String mainScreen = 'main';
  static const String orderDetailsScreen = 'order-details';
  static const String orderRatingScreen = 'order-rating';
  static const String pdfViewerScreen = 'pdf-viewer';
  static const String cartScreen = 'cart';
  static const String categoriesScreen = 'categories';
  static const String categoryDetailsScreen = 'category-details';
  static const String favouritesScreen = 'favourites';
  static const String walletScreen = 'wallet';
  static const String fileComplaintScreen = 'file-complaint';
  static const String topBrandsScreen = 'top-brands';
  static const String mostPopularScreen = 'most-popular';
  static const String offersCannotWaitScreen = 'offers-cannot-wait';
  static const String homeNeverMissOffersScreen = 'home-never-miss-offers';
  static const String notificationsScreen = 'notifications';
  static const String searchScreen = 'search';
  static const String allStoresScreen = 'all-stores';
  static const String viewStoreCategoryProductsScreen =
      'store-category-products';
  static const String storeDetailsScreen = 'store-details';
  static const String productDetailsScreen = 'product-details';
  static const String checkoutScreen = 'checkout';
  static const String addPaymentCard = 'add-payment-card';
  static const String paymentMethodsScreen = 'payment-methods';
  static const String phoneVerificationScreen = 'phone-verification';
  static const String otpVerificationScreen = 'otp-verification';
  static const String personalInformationScreen = 'personal-information';
  static const String completeProfileScreen = 'complete-profile';
  static const String orderConfirmedScreen = 'order-confirmed';
  static const String trackOrderScreen = 'track-order';
  static const String paymentFailedScreen = 'payment-failed';
  static const String myAddressScreen = 'my-address';
  static const String addressDetailsScreen = 'address-details';
  static const String addNewAddressFromMapScreen = 'add-address-from-map';
  static const String addressSearchScreen = 'address-search';
  static const String discountCodeScreen = 'discount-code';
  static const String supportScreen = 'support';
  static const String faqScreen = 'faq';
  static const String supportFaqsScreen = 'support-faqs';
  static const String privacyPolicyScreen = 'privacy-policy';
  static const String editInformationScreen = 'edit-information';
}
