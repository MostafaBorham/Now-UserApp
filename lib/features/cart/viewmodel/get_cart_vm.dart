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
/// cart screen must not throw the loaded cart away). It is disposed only on
/// logout via `ref.invalidate(getCartProvider)`.
final getCartProvider =
    StateNotifierProvider<GetCartViewModel, AsyncValue<CartModel>>(
  (Ref ref) => GetCartViewModel(const AsyncValue.loading())..getCart(),
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
}
