import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/data/repo/cart_repo.dart';












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




  void updateCartState(CartModel newCart) {
    state = AsyncValue.data(newCart);
  }







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
  }



  void clearVendors() {
    final CartModel? cart = state.valueOrNull;

    if (cart == null) return;

    state = AsyncValue.data(cart.copyWith(vendors: const <CartVendorModel>[]));
  }
}
