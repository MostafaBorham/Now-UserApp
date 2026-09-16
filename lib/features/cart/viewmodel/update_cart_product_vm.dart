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

  bool _joinedCart = false;
  bool _feedbackPending = false;

  /// Whether the update that just settled put this product in the cart for the
  /// first time, rather than changing a line that was already there. Read it
  /// when a success lands: it is what separates the confirmation sheet from the
  /// plain quantity toast.
  ///
  /// It is answered from the cart as it stood before the request, so with the
  /// cart not loaded yet an add reads as a first one — which is what it almost
  /// always is.
  bool get joinedCart => _joinedCart;

  /// Claims the right to confirm the update that just settled: true for the
  /// first caller, false for everyone after it.
  ///
  /// One product can be on screen in several places at once — the same card in
  /// two home sections, a listing behind an open sheet — and they all listen to
  /// this one notifier. Without this they would each answer the same response,
  /// stacking duplicate toasts and sheets.
  bool claimFeedback() {
    if (!_feedbackPending) return false;

    _feedbackPending = false;
    return true;
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  /// Sets this product's cart line to [productQuantity]; `0` removes it.
  Future<void> updateCartProductQuantity(int productQuantity) =>
      _send(() => _repo.updateCartProductQuantity(_productId, productQuantity));

  /// Puts [productQuantity] of this product in the cart.
  Future<void> addToCart(int productQuantity) =>
      _send(() => _repo.addToCart(_productId, productQuantity));

  Future<void> _send(
    Future<Either<Failure, CartModel>> Function() request,
  ) async {
    state = const AsyncValue<CartModel?>.loading();

    final Either<Failure, CartModel> result = await request();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue<CartModel?>.error(failure.message, StackTrace.current),
      (CartModel cart) {
        // Read before the refresh below: until then the shared cart still holds
        // this product's quantity as it was before the request.
        _joinedCart =
            (_ref.read(getCartProvider).valueOrNull?.quantityOf(_productId) ??
                0) ==
            0;
        _feedbackPending = true;
        _ref.read(getCartProvider.notifier).updateCartState(cart);
        return AsyncValue<CartModel?>.data(cart);
      },
    );
  }
}
