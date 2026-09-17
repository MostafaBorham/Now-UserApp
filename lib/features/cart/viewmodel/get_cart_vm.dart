import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/data/repo/cart_repo.dart';

/// Single task: fetch the cart (vendors, lines and pricing) for the cart
/// screen.
///
/// The fetch starts as soon as the provider is first watched, so screens only
/// need to `ref.watch(getCartProvider)` and render the [AsyncValue].
/// Retry with `ref.read(getCartProvider.notifier).getCart()`.
///
/// This provider is intentionally **not** `autoDispose`: the cart is shared
/// state that must survive the whole app life cycle (navigating away from the
/// cart screen must not throw the loaded cart away). Surviving a *session*
/// change is a different matter — it is listed in `sessionScopedProviders`
/// (`features/auth/viewmodel/auth_session_vm.dart`), which is what invalidates
/// it whenever the signed-in user changes.
///
/// That listing is load-bearing, not documentation. Screens here only fetch
/// when the provider is empty, so a cart left behind by the previous user is
/// never refetched — it is simply shown to the next one.
final getCartProvider =
    StateNotifierProvider<GetCartViewModel, AsyncValue<CartModel>>(
      (Ref ref) => GetCartViewModel(const AsyncValue.loading()),
    );

class GetCartViewModel extends StateNotifier<AsyncValue<CartModel>> {
  GetCartViewModel(super.initialState);

  final CartRepo _repo = CartRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getCart() async {
    state = const AsyncValue.loading();

    final result = await _repo.getCart();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (CartModel cart) => AsyncValue.data(cart),
    );
  }

  /// Replaces the current cart with [newCart], the fresh cart returned by an
  /// update/delete request, so the screen reflects the server truth without a
  /// refetch.
  void updateCartState(CartModel newCart) {
    state = AsyncValue.data(newCart);
  }

  /// Drops the store [vendorId] from the loaded cart, after that single store
  /// has been checked out — its products now belong to a draft order group, so
  /// the cart must stop offering them.
  ///
  /// The local edit is only what the shopper sees on the way back; [getCart] is
  /// then fired to replace it. Leaving the edit to stand would keep every
  /// remaining store on its pre-checkout pricing, which is wrong the moment a
  /// coupon or a delivery-fee threshold spanned more than one of them — and the
  /// cart screen fetches only when it has no value, so nothing else would ever
  /// correct it.
  ///
  /// A no-op while the cart itself is loading or in error: there is nothing
  /// loaded to remove from, and the refetch brings the server truth anyway.
  void removeVendor(int vendorId) {
    final CartModel? cart = state.valueOrNull;

    if (cart == null) return;

    state = AsyncValue.data(
      cart.copyWith(
        vendors: cart.vendors
            .where((CartVendorModel vendor) => vendor.vendor.id != vendorId)
            .toList(),
      ),
    );

    _refreshInBackground();
  }

  /// Drops every store from the loaded cart, after all of them have been
  /// checked out together. Same rules as [removeVendor].
  void clearVendors() {
    final CartModel? cart = state.valueOrNull;

    if (cart == null) return;

    state = AsyncValue.data(cart.copyWith(vendors: const <CartVendorModel>[]));

    _refreshInBackground();
  }

  /// Refetches without going through the `loading` state, so the optimistic
  /// edit above stays on screen instead of flashing the shimmer at a shopper
  /// who is being pushed to the confirmation screen anyway.
  Future<void> _refreshInBackground() async {
    final result = await _repo.getCart();

    if (!mounted) return;

    // A failed refresh keeps the local edit: it is the better of the two
    // answers available, and the next open refetches.
    result.fold(
      (Failure _) {},
      (CartModel cart) => state = AsyncValue.data(cart),
    );
  }
}
