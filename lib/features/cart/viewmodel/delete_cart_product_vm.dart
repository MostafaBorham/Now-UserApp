import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/data/repo/cart_repo.dart';











final deleteCartProductProvider = StateNotifierProvider.autoDispose
    .family<DeleteCartProductViewModel, AsyncValue<CartModel?>, int>(
  (Ref ref, int productId) => DeleteCartProductViewModel(productId),
);

class DeleteCartProductViewModel extends StateNotifier<AsyncValue<CartModel?>> {
  DeleteCartProductViewModel(this._productId)
      : super(const AsyncValue<CartModel?>.data(null));

  final int _productId;
  final CartRepo _repo = CartRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> deleteCartProduct() async {
    state = const AsyncValue<CartModel?>.loading();

    final Either<Failure, CartModel> result =
        await _repo.deleteCartProduct(_productId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue<CartModel?>.error(failure.message, StackTrace.current),
      (CartModel cart) => AsyncValue<CartModel?>.data(cart),
    );
  }
}
