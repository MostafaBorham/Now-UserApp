import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/data/repo/cart_repo.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';

/// One-shot action: change the quantity of a single cart line.
///
/// Keyed by `productId` so each product's update is tracked independently and
/// resets automatically once the widget watching it disposes (autoDispose).
///
/// State semantics on `AsyncValue<CartModel?>`:
/// - `AsyncData(null)`      → idle, nothing requested yet (initial),
/// - `AsyncLoading`         → request in flight,
/// - `AsyncData(CartModel)` → succeeded; carries the fresh cart,
/// - `AsyncError`           → failed; carries the user-facing message.
final updateCartProductProvider = StateNotifierProvider.autoDispose
    .family<UpdateCartProductViewModel, AsyncValue<CartModel?>, int>(
  (Ref ref, int productId) => UpdateCartProductViewModel(ref, productId),
);

class UpdateCartProductViewModel extends StateNotifier<AsyncValue<CartModel?>> {
  UpdateCartProductViewModel(this._ref, this._productId)
      : super(const AsyncValue<CartModel?>.data(null));

  final Ref _ref;
  final int _productId;
  final CartRepo _repo = CartRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> updateCartProductQuantity(int productQuantity) async {
    state = const AsyncValue<CartModel?>.loading();

    final Either<Failure, CartModel> result =
        await _repo.updateCartProductQuantity(_productId, productQuantity);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue<CartModel?>.error(failure.message, StackTrace.current),
      (CartModel cart) {
        _ref.read(getCartProvider.notifier).updateCartState(cart);
        return AsyncValue<CartModel?>.data(cart);
      },
    );
  }
  Future<void> addToCart(int productQuantity) async {
    state = const AsyncValue<CartModel?>.loading();

    final Either<Failure, CartModel> result =
    await _repo.addToCart(_productId, productQuantity);

    if (!mounted) return;

    state = result.fold(
          (Failure failure) =>
      AsyncValue<CartModel?>.error(failure.message, StackTrace.current),
          (CartModel cart) {
        _ref.read(getCartProvider.notifier).updateCartState(cart);
        return AsyncValue<CartModel?>.data(cart);
      },
    );
  }
}
