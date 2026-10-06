abstract class LangKeys {
  // App / auth / onboarding (existing)
  static const String appNameKey = 'appName';
  static const String loginKey = 'login';
  static const String loginOrRegisterKey = 'loginOrRegister';
  static const String promoCodeKey = 'promoCode';
  static const String onFirstOrderKey = 'onFirstOrder';
  static const String orKey = 'or';
  static const String onBoardingTitleKey = 'onBoardingTitle';
  static const String onBoardingSubTitleKey = 'onBoardingSubTitle';
  static const String searchHintKey = 'searchHint';
  static const String categoriesKey = 'categories';
  static const String purchaseVoucherKey = 'purchaseVoucher';
  static const String offersKey = 'offers';
  static const String topBrandsKey = 'topBrands';
  static const String mostPopularKey = 'mostPopular';
  static const String categoriesTitleKey = 'categoriesTitle';
  static const String discountKey = 'discount';
  static const String discountTitle = 'discountScreenTitle';
  static const String discountMinPurchase = 'discountMinPurchase';
  static const String discountOnAllStores = 'discountOnAllStores';
  static const String discountOnSelectedCategoriesKey =
      'discountOnSelectedCategories';
  static const String discountOnSelectedProductsKey =
      'discountOnSelectedProducts';
  static const String rankKey = 'rank';
  static const String newArrivalKey = 'newArrival';
  static const String exclusiveKey = 'exclusive';
  static const String addToCartKey = 'addToCart';
  static const String productAddedToCartKey = 'productAddedToCart';
  static const String productRemovedFromCartKey = 'productRemovedFromCart';
  static const String cartQuantityUpdatedKey = 'cartQuantityUpdated';
  static const String addMoreItemsKey = 'addMoreItems';
  static const String soldKey = 'sold';
  static const String hotKey = 'hot';
  static const String faq = 'faq';
  static const String privacy = 'privacy';
  static const String language = 'language';
  static const String languageAr = 'languageAr';
  static const String languageEn = 'languageEn';

  static const String general = 'general';
  static const String cartKey = 'cart';
  static const String checkoutKey = 'checkout';
  static const String myAddress = 'myAddress';
  static const String proActivity = 'promotionalActivity';
  static const String discount = 'discountCode';
  static const String discountCodes = 'discountCodes';
  static const String descriptionKey = 'description';
  static const String myWallet = 'myWallet';
  static const String supportLabel = 'support';
  static const String liveChat = 'liveChat';
  static const String faqs = 'faqs';
  static const String privacyPolicy = 'privacyPolicy';
  static const String logout = 'logout';

  // Privacy screen header (static labels; the date comes from the backend)
  static const String privacyEffectiveDate = 'privacyEffectiveDate';
  static const String privacyIntro = 'privacyIntro';

  // Privacy screen section titles (content comes from the app-info backend)
  static const String appTerms = 'appTerms';
  static const String appPrivacy = 'appPrivacy';
  static const String appAbout = 'appAbout';

  // Categories & favourites
  static const String productsKey = 'products';
  static const String storesKey = 'stores';
  static const String favouriteKey = 'favourite';
  static const String emptyFavouritesKey = 'emptyFavourites';
  static const String allKey = 'all';
  static const String otherKey = 'other';
  static const String filtersKey = 'filters';
  static const String searchForAProductKey = 'searchForAProduct';
  static const String searchForAStoreKey = 'searchForAStore';
  static const String cashOnDeliveryKey = 'cashOnDeliveryKey';

  static const String area = 'area';
  static const String failedToGetArea = 'failedToGetArea';
  static const String failedToGetAddress = 'failedToGetAddress';
  static const String change = 'change';
  static const String homeAddressSelector = 'homeAddressSelector';
  static const String workAddressSelector = 'workAddressSelector';
  static const String otherAddressSelector = 'otherAddressSelector';
  // First two address fields are re-labelled when the "work" label is selected.
  static const String floor = 'floor';
  static const String floorWork = 'floorWork';
  static const String floorNumberOptional = 'floorNumberOptional';
  static const String building = 'building';
  static const String apartment = 'apartment';
  static const String phoneNumberOptional = 'phoneNumberOptional';
  static const String instructions = 'instructions';

  /// An address line's parts: "Floor 3", "Apartment 12" (`{}` is the value).
  static const String floorValueKey = 'floorValue';
  static const String apartmentValueKey = 'apartmentValue';

  static const String saveAddress = 'saveAddress';
  static const String completeAddressInfo = 'completeAddressInfo';
  static const String enterValidMobileNumber = 'enterValidMobileNumber';
  static const String editAddress = 'editAddress';
  static const String addressDetails = 'addressDetails';
  static const String addNewAddress = 'addNewAddress';
  static const String changeAddress = 'changeAddress';
  static const String enterAddressKey = 'enterAddress';
  static const String defaultAddress = 'defaultAddress';
  static const String noSavedAddresses = 'noSavedAddresses';
  static const String addressDeletedSuccessfully = 'addressDeletedSuccessfully';
  static const String deleteAddressConfirmationKey =
      'deleteAddressConfirmation';
  static const String deleteCardConfirmationKey = 'deleteCardConfirmation';
  static const String failedToLoadImageKey = 'failedToLoadImage';
  static const String topUpUnconfirmedKey = 'topUpUnconfirmed';
  static const String cardAlreadySavedKey = 'cardAlreadySaved';

  // Bottom navigation
  static const String homeKey = 'home';
  static const String ordersKey = 'orders';
  static const String expiryDateHintKey = 'expiryDateHintKey';
  static const String expiredKey = 'expiredKey';
  static const String orderKey = 'order';
  static const String profileKey = 'profile';
  static const String deliveredOnKey = 'deliveredOnKey';

  /// Plural (`'…'.plural(n)`): "3 items" / "٣ منتجات", with Arabic's forms.
  static const String itemsCountKey = 'itemsCount';
  static const String imagePickingErrorKey = 'imagePickingErrorKey';
  static const String searchForBrandKey = 'searchForBrandKey';

  // Home
  static const String shopNowKey = 'shopNow';
  static const String offersYouCannotWaitForKey = 'offersYouCannotWaitFor';
  static const String homeGreetingKey = 'homeGreeting';
  static const String bestNearbyStoresKey = 'bestNearbyStores';
  static const String specialOffersKey = 'specialOffers';
  static const String allStoresKey = 'allStores';
  static const String minutesKey = 'minutes';
  static const String kmKey = 'km';

  // Onboarding
  static const String continueAsGuestKey = 'continueAsGuest';

  // Wallet
  static const String walletKey = 'wallet';
  static const String support = 'supportTitle';
  static const String walletRecordKey = 'walletRecord';
  static const String nowCreditKey = 'nowCredit';
  static const String addBalanceKey = 'addBalance';
  static const String myCardsKey = 'myCards';
  static const String addCardKey = 'addCard';
  static const String addNewCardKey = 'addNewCard';
  static const String continueKey = 'continue';
  static const String topUpKey = 'topUp';
  static const String selectPaymentMethodFirstKey = 'selectPaymentMethodFirst';
  static const String topUpAmountKey = 'topUpAmount';
  static const String enterAmountKey = 'enterAmount';
  static const String maximumKey = 'maximum';
  static const String noCardsYetKey = 'noCardsYet';
  static const String paymentMethodKey = 'paymentMethod';
  static const String cardholderNameKey = 'cardholderName';
  static const String nameHintKey = 'nameHint';
  static const String cardNumberKey = 'cardNumber';
  static const String expirationDateKey = 'expirationDate';
  static const String cardAddedSuccessfullyKey = 'cardAddedSuccessfully';
  static const String cardUpdatedSuccessfullyKey = 'cardUpdatedSuccessfully';
  static const String editCardKey = 'editCard';
  static const String requiredFieldKey = 'requiredField';
  static const String invalidCardNumberKey = 'invalidCardNumber';
  static const String invalidExpiryDateKey = 'invalidExpiryDate';
  static const String cardExpiredKey = 'cardExpired';
  static const String invalidCvvKey = 'invalidCvv';
  static const String setAsDefaultKey = 'setAsDefault';

  // Payment methods
  static const String paymentMethodsKey = 'paymentMethods';
  static const String savedCardsKey = 'savedCards';
  static const String anotherPaymentMethodKey = 'anotherPaymentMethod';
  static const String applePayKey = 'applePay';
  static const String stcPayKey = 'stcPay';
  static const String cvvKey = 'cvv';
  static const String addKey = 'add';
  static const String addNewPaymentCardKey = 'addNewPaymentCard';

  // Guest verification
  static const String verificationCodeKey = 'verificationCode';
  static const String verifyGuestViaPhoneKey = 'verifyGuestViaPhone';
  static const String phoneVerificationSubtitleKey =
      'phoneVerificationSubtitle';
  static const String mobileNumberKey = 'mobileNumber';
  static const String enterVerificationCodeKey = 'enterVerificationCode';
  static const String otpSentToKey = 'otpSentTo';
  static const String enterCodeToContinueKey = 'enterCodeToContinue';
  static const String didNotReceiveCodeKey = 'didNotReceiveCode';
  static const String resendKey = 'resend';
  static const String resetFilterKey = 'resetFilter';
  static const String pasteCodeKey = 'pasteCode';
  static const String personalInformationKey = 'personalInformation';
  static const String editInformationKey = 'editInformation';
  static const String saveKey = 'save';
  static const String takePhotoKey = 'takePhoto';
  static const String chooseFromGalleryKey = 'chooseFromGallery';
  static const String removePhotoKey = 'removePhoto';

  // Personal information (read-only profile) screen
  static const String fullNameKey = 'fullName';
  static const String firstNameKey = 'firstName';
  static const String lastNameKey = 'lastName';
  static const String phoneKey = 'phone';
  static const String emailKey = 'email';
  static const String genderKey = 'gender';
  static const String maleKey = 'male';
  static const String femaleKey = 'female';
  static const String dateOfBirthKey = 'dateOfBirth';
  static const String enterEmailAddressKey = 'enterEmailAddress';
  static const String selectDateOfBirthKey = 'selectDateOfBirth';

  static const String nameKey = 'name';
  static const String firstNameHintKey = 'firstNameHint';
  static const String lastNameHintKey = 'lastNameHint';
  static const String nameRequiredKey = 'nameRequired';
  static const String emailOptionalKey = 'emailOptional';
  static const String enterYourEmailKey = 'enterYourEmail';

  // Orders
  static const String myOrdersKey = 'myOrders';
  static const String orderDetailsKey = 'orderDetails';
  static const String orderNumberKey = 'orderNumber';
  static const String orderDateKey = 'orderDate';
  static const String deliveredKey = 'delivered';
  static const String pendingKey = 'pending';
  static const String viewDetailsKey = 'viewDetails';
  static const String trackOrderKey = 'trackOrder';
  static const String generalInformationKey = 'generalInformation';
  static const String itemInformationKey = 'itemInformation';
  static const String deliveryDetailsKey = 'deliveryDetails';
  static const String fromKey = 'from';
  static const String toKey = 'to';
  static const String productDetailsKey = 'productDetails';
  static const String invoiceSummaryKey = 'invoiceSummary';
  static const String storeInvoiceSummaryKey = 'storeInvoiceSummary';
  static const String subtotalKey = 'subtotal';
  static const String vatKey = 'vat';
  static const String deliveryFeesKey = 'deliveryFees';
  static const String discountLabelKey = 'discountLabel';
  static const String totalKey = 'total';
  static const String printInvoiceKey = 'printInvoice';
  static const String invoiceDownloadFailedKey = 'invoiceDownloadFailed';

  // Order tracking (Order Confirmed / Track Order / Payment Failed)
  static const String orderConfirmedTitleKey = 'orderConfirmedTitle';
  static const String orderConfirmedSubtitleKey = 'orderConfirmedSubtitle';
  static const String returnToHomePageKey = 'returnToHomePage';
  static const String receiverKey = 'receiver';
  static const String addressKey = 'address';
  static const String contactKey = 'contact';
  static const String storeKey = 'store';
  static const String storeUnavailableKey = 'storeUnavailable';
  static const String numberOfItemsKey = 'numberOfItems';
  static const String paymentKey = 'payment';
  static const String payKey = 'pay';
  static const String courierKey = 'courier';
  static const String estimatedDeliveryTimeKey = 'estimatedDeliveryTime';
  static const String orderAcceptedKey = 'orderAccepted';
  static const String orderConfirmedBeingPreparedKey =
      'orderConfirmedBeingPrepared';
  static const String onTheWayToYouKey = 'onTheWayToYou';

  // Order-status descriptions shown under the order number in the my-orders list
  static const String awaitingOrderConfirmationKey =
      'awaitingOrderConfirmation';
  static const String preparingYourOrderKey = 'preparingYourOrder';
  static const String orderOnTheWayKey = 'orderOnTheWay';
  static const String refundedOnKey = 'refundedOnKey';
  static const String cancelOrderKey = 'cancelOrder';
  static const String paymentNotCompletedKey = 'paymentNotCompleted';
  static const String paymentFailedSubtitleKey = 'paymentFailedSubtitle';
  static const String cardDeclinedTitleKey = 'cardDeclinedTitle';
  static const String cardDeclinedBodyKey = 'cardDeclinedBody';
  static const String orderItemOutOfStockKey = 'orderItemOutOfStock';
  static const String amountDueKey = 'amountDue';
  static const String tryAnotherPaymentMethodKey = 'tryAnotherPaymentMethod';
  static const String paymentCardKey = 'paymentCard';
  static const String backToOrderKey = 'backToOrder';
  static const String areYouSureCancelKey = 'areYouSureCancel';
  static const String cancelOrderWarningKey = 'cancelOrderWarning';
  static const String yesCancelOrderKey = 'yesCancelOrder';
  static const String keepOrderKey = 'keepOrder';
  static const String orderCanceledTitleKey = 'orderCanceledTitle';
  static const String orderCanceledSubtitleKey = 'orderCanceledSubtitle';
  static const String continueShoppingKey = 'continueShopping';
  static const String viewOrdersKey = 'viewOrders';

  // Complaints & rating
  static const String fileComplaintKey = 'fileComplaint';
  static const String submitComplaintKey = 'submitComplaint';
  static const String submitAComplaintKey = 'submitAComplaint';
  static const String complaintPhotosKey = 'complaintPhotos';
  static const String complaintDescriptionRequiredKey =
      'complaintDescriptionRequired';
  static const String complaintSubmittedSuccessfullyKey =
      'complaintSubmittedSuccessfully';
  static const String tellUsMoreKey = 'tellUsMore';
  static const String orderReadyToRateKey = 'orderReadyToRate';
  static const String orderArrivedRatePromptKey = 'orderArrivedRatePrompt';
  static const String rateOrderKey = 'rateOrder';
  static const String orderRatingKey = 'orderRating';
  static const String theRatingKey = 'theRating';
  static const String shareExperienceToImproveKey = 'shareExperienceToImprove';
  static const String rateProductsKey = 'rateProducts';
  static const String deliveryAgentKey = 'deliveryAgent';
  static const String writeYourCommentHereKey = 'writeYourCommentHere';
  static const String submitRatingKey = 'submitRating';
  static const String thanksForRatingKey = 'thanksForRating';
  static const String ratingRequiredKey = 'ratingRequired';
  static const String ratingCommentNeedsStarsKey = 'ratingCommentNeedsStars';

  // Errors & states
  static const String noItemsYetKey = 'noItemsYet';
  static const String noFaqsYetKey = 'noFaqsYet';
  static const String serverConnectionFailedKey = 'serverConnectionFailed';
  static const String somethingWentWrongKey = 'somethingWentWrong';
  static const String unableToReachServersKey = 'unableToReachServers';
  static const String retryKey = 'retry';
  static const String showingSavedContentKey = 'showingSavedContent';
  static const String errorTitleKey = 'errorTitle';
  static const String successTitleKey = 'successTitle';
  static const String noInternetConnectionKey = 'noInternetConnection';
  static const String saveGuestSessionFailedKey = 'saveGuestSessionFailed';
  static const String saveUserSessionFailedKey = 'saveUserSessionFailed';
  static const String clearUserSessionFailedKey = 'clearUserSessionFailed';
  static const String readRecentSearchesFailedKey = 'readRecentSearchesFailed';
  static const String saveRecentSearchesFailedKey = 'saveRecentSearchesFailed';
  static const String clearRecentSearchesFailedKey =
      'clearRecentSearchesFailed';

  // Notifications
  static const String notificationsKey = 'notifications';
  static const String todayKey = 'today';
  static const String yesterdayKey = 'yesterday';
  static const String justNowKey = 'justNow';

  // Search
  static const String searchKey = 'search';
  static const String recentKey = 'recent';
  static const String oldestKey = 'oldest';
  static const String clearKey = 'clear';
  static const String bestCategoriesKey = 'bestCategories';
  static const String seeAllKey = 'seeAll';
  static const String seeAllCategoriesKey = 'seeAllCategories';
  static const String seeMoreKey = 'seeMore';
  static const String mostRequestedKey = 'mostRequested';
  static const String moreFiltersKey = 'moreFilters';
  static const String ratingsKey = 'ratings';
  static const String applyFiltersKey = 'applyFilters';
  static const String sortOptionsKey = 'sortOptions';
  static const String topRatedKey = 'topRated';
  static const String priceHighestToLowestKey = 'priceHighestToLowest';
  static const String priceLowestToHighestKey = 'priceLowestToHighest';
  static const String minimumLimitKey = 'minimumLimit';
  static const String noResultFoundKey = 'noResultFound';

  // Checkout
  static const String applyKey = 'apply';
  static const String appliedKey = 'applied';
  static const String voucherApplyFailedKey = 'voucherApplyFailed';
  static const String couponNeedsStoreInCartKey = 'couponNeedsStoreInCart';

  // A vendor carries one discount, so applying a coupon cancels that vendor's
  // voucher and vice versa; these announce the swap.
  static const String couponReplacedByVoucherKey = 'couponReplacedByVoucher';
  static const String voucherReplacedByCouponKey = 'voucherReplacedByCoupon';
  static const String confirmOrderKey = 'confirmOrder';
  static const String confirmAddressKey = 'confirmAddress';
  static const String currentLocationKey = 'currentLocation';
  static const String deliveryAddressKey = 'deliveryAddress';
  static const String deliveryInstructionsKey = 'deliveryInstructions';
  static const String addInstructionsHintKey = 'addInstructionsHint';
  static const String editKey = 'edit';
  static const String noAddressKey = 'noAddress';
  static const String setYourLocationKey = 'setYourLocation';
  static const String noDeliveryAddressSelectedKey =
      'noDeliveryAddressSelected';
  static const String pleaseSelectAddressKey = 'pleaseSelectAddress';
  static const String choosePaymentMethodKey = 'choosePaymentMethod';
  static const String addWalletKey = 'addWallet';
  static const String balanceKey = 'balance';
  static const String walletShortfallHintKey = 'walletShortfallHint';
  static const String walletBalanceNotUpdatedKey = 'walletBalanceNotUpdated';
  static const String tipYourDriverKey = 'tipYourDriver';
  static const String driverTipKey = 'driverTip';

  // Cart
  static const String cartEmptyTitleKey = 'cartEmptyTitle';
  static const String cartEmptySubtitleKey = 'cartEmptySubtitle';
  static const String browseProductsKey = 'browseProducts';
  static const String removeProductKey = 'removeProduct';
  static const String removeProductConfirmationKey =
      'removeProductConfirmation';
  static const String deleteAllKey = 'deleteAll';

  /// Why a store's checkout pill is disabled. `cartMinOrderNotMet` takes a
  /// `{amount}` — how much short of the store's minimum the basket still is.
  static const String cartMinOrderNotMetKey = 'cartMinOrderNotMet';
  static const String cartStoreUnavailableKey = 'cartStoreUnavailable';

  static const String removeItemFromCartKey = 'removeItemFromCart';
  static const String removeItemFromCartConfirmationKey =
      'removeItemFromCartConfirmation';
  static const String cancelKey = 'cancel';
  static const String deleteKey = 'delete';

  // Dialogs
  static const String logoutConfirmationKey = 'logoutConfirmation';

  // Product details
  static const String buyNowKey = 'buyNow';
  static const String basicSpecificationsKey = 'basicSpecifications';
  static const String keyFeaturesKey = 'keyFeatures';
  static const String chooseColorKey = 'chooseColor';
  static const String selectRequiredKey = 'selectRequired';
  static const String inTheShoppingCartKey = 'inTheShoppingCart';
  static const String viewCartKey = 'viewCart';
  static const String trustedProductKey = 'trustedProduct';
  static const String outOfStockKey = 'outOfStock';

  // Address search
  static const String searchForAddressKey = 'searchForAddress';
  static const String noAddressResultsKey = 'noAddressResults';

  // Clipboard
  static const String codeCopiedKey = 'codeCopied';

  // Store details
  static const String storeCategoriesKey = 'storeCategories';

  // Welcome voucher (empty cart, first order). Fragments so the code and the
  // "discount" word can be styled individually.
  static const String welcomeVoucherPrefixKey = 'welcomeVoucherPrefix';
  static const String welcomeVoucherMiddleKey = 'welcomeVoucherMiddle';
  static const String welcomeVoucherDiscountKey = 'welcomeVoucherDiscount';
  static const String welcomeVoucherSuffixKey = 'welcomeVoucherSuffix';

  // Personal information - editing
  static const String invalidEmailKey = 'invalidEmail';
  static const String profileUpdatedKey = 'profileUpdated';
  static const String discardChangesKey = 'discardChanges';
  static const String discardChangesMessageKey = 'discardChangesMessage';
  static const String discardKey = 'discard';

  // Home - live orders section
  static const String preparingKey = 'preparing';
  static const String onTheWayKey = 'onTheWay';
}
