import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
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
/// That listing is load-bearing, not documentation. Only the cart tab refetches
/// a loaded cart, and only when it is opened — every product card just reads
/// it — so a cart left behind by the previous user would be shown to the next.
final getCartProvider =
    StateNotifierProvider<GetCartViewModel, AsyncValue<CartModel>>(
      (Ref ref) => GetCartViewModel(const AsyncValue.loading()),
    );

class GetCartViewModel extends StateNotifier<AsyncValue<CartModel>> {
  /// [repo] is injectable for tests, like [CartRepo]'s own collaborators.
  GetCartViewModel(super.initialState, {CartRepo? repo})
    : _repo = repo ?? CartRepo();

  final CartRepo _repo;

  /// Bumped by every cart a mutation hands back, so a [refresh] that was
  /// already in flight can tell its answer is older than what is on screen.
  int _mutations = 0;

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
    _mutations++;
    state = AsyncValue.data(newCart);
  }

  /// Sets each line in [fixes] to its quantity (see
  /// [CartVendorModel.stockFixes]), one request at a time, and returns why one
  /// was refused — null when they all landed.
  ///
  /// Removals go first: the server checks each change against the product's
  /// other lines as they still stand, so a line trimmed while a sibling still
  /// holds the stock would be refused. Stops at the first refusal; what landed
  /// before it stays.
  Future<String?> fitToStock(Map<ProductModel, int> fixes) async {
    final List<MapEntry<ProductModel, int>> ordered = fixes.entries.toList()
      ..sort(
        (MapEntry<ProductModel, int> a, MapEntry<ProductModel, int> b) =>
            a.value.compareTo(b.value),
      );

    for (final MapEntry<ProductModel, int> fix in ordered) {
      final int? productId = fix.key.productId ?? fix.key.id;
      if (productId == null) continue;

      final result = await _repo.updateCartProductQuantity(
        productId,
        fix.value,
        cartItemId: fix.key.cartItemId,
      );

      if (!mounted) return null;

      final String? error = result.fold((Failure failure) => failure.message, (
        CartModel cart,
      ) {
        updateCartState(cart);
        return null;
      });
      if (error != null) return error;
    }
    return null;
  }

  /// Drops the store [vendorId] from the loaded cart, after that single store
  /// has been checked out — its products now belong to a draft order group, so
  /// the cart must stop offering them.
  ///
  /// The local edit is only what the shopper sees on the way back; [refresh] is
  /// then fired to replace it. Leaving the edit to stand would keep every
  /// remaining store on its pre-checkout pricing, which is wrong the moment a
  /// coupon or a delivery-fee threshold spanned more than one of them.
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

    refresh();
  }

  /// Drops every store from the loaded cart, after all of them have been
  /// checked out together. Same rules as [removeVendor].
  void clearVendors() {
    final CartModel? cart = state.valueOrNull;

    if (cart == null) return;

    state = AsyncValue.data(cart.copyWith(vendors: const <CartVendorModel>[]));

    refresh();
  }

  /// Refetches without going through the `loading` state, so whatever is on
  /// screen stays there: the cart tab on open and on pull, and the optimistic
  /// edits above. Going through `loading` swapped the cart for its shimmer and,
  /// while it reloaded, left every product card in the app without its count.
  ///
  /// A failure keeps what is loaded and is returned (null on success) for the
  /// caller to report. An answer that lost a race to a mutation is dropped: the
  /// mutation's cart is newer than the one this request fetched.
  Future<String?> refresh() async {
    final int mutationsBefore = _mutations;
    final result = await _repo.getCart();

    if (!mounted) return null;

    return result.fold((Failure failure) => failure.message, (CartModel cart) {
      if (_mutations == mutationsBefore) state = AsyncValue.data(cart);
      return null;
    });
  }
}
