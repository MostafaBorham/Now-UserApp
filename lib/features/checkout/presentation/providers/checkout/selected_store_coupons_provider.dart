import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The coupons the shopper picked from a store's details screen, as
/// `vendorId → code`.
///
/// The bridge between the store-details coupon strip and checkout: a tap there
/// records the code here, and that vendor's `ApplyDiscountCodeView` applies it
/// to the draft as soon as its card is on screen. Entries are dropped when the
/// shopper removes the applied chip or the server rejects the code, so the
/// strip and the checkout card never disagree.
///
/// Kept alive on purpose — nothing watches it between the two screens, so an
/// `autoDispose` one would forget the pick the moment the store screen is
/// popped. That is also why it is listed in `sessionScopedProviders`: a pick
/// made by one user must not ride into the next user's checkout.
final selectedStoreCouponsProvider = StateProvider<Map<int, String>>(
  (Ref ref) => const <int, String>{},
);
