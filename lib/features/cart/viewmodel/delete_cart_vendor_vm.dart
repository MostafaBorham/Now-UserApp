import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/data/repo/cart_repo.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';















final deleteCartVendorProvider = StateNotifierProvider.autoDispose
    .family<DeleteCartVendorViewModel, AsyncValue<CartModel?>, int>(
  (Ref ref, int vendorId) => DeleteCartVendorViewModel(ref, vendorId),
);

class DeleteCartVendorViewModel extends StateNotifier<AsyncValue<CartModel?>> {
  DeleteCartVendorViewModel(this._ref, this._vendorId)
      : super(const AsyncValue<CartModel?>.data(null));

  final Ref _ref;
  final int _vendorId;
  final CartRepo _repo = CartRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> deleteCartVendor() async {
    state = const AsyncValue<CartModel?>.loading();

    final Either<Failure, CartModel> result =
        await _repo.deleteCartVendorItem(_vendorId);

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
