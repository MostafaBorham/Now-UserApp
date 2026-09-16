import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/data/repo/cart_repo.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';

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
  Future<void> addToCart(
    int productQuantity, [
    Map<String, dynamic>? options,
  ]) async {
    state = const AsyncValue<CartModel?>.loading();

    final Either<Failure, CartModel> result =
    await _repo.addToCart(_productId, productQuantity, options);

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
