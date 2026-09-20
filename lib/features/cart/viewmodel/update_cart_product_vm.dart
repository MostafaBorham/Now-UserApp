import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/data/repo/cart_repo.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';

/// Keyed by a *lane id*, not always a product id: an add-to-cart lane is keyed
/// by the product id (there is no line yet), while a cart line is keyed by its
/// `cart_item_id` so two variants of one product don't share a spinner or a
/// feedback claim. The lane id doubles as the product id only for [addToCart].
final updateCartProductProvider = StateNotifierProvider.autoDispose
    .family<UpdateCartProductViewModel, AsyncValue<CartModel?>, int>(
      (Ref ref, int laneId) => UpdateCartProductViewModel(ref, laneId),
    );

class UpdateCartProductViewModel extends StateNotifier<AsyncValue<CartModel?>> {
  UpdateCartProductViewModel(this._ref, this._laneId)
    : super(const AsyncValue<CartModel?>.data(null));

  final Ref _ref;
  final int _laneId;
  final CartRepo _repo = CartRepo();

  int _previousQuantity = 0;
  bool _feedbackPending = false;

  /// This product's quantity as the cart stood *before* the update that just
  /// settled. Read it when a success lands: compared against the fresh cart it
  /// is what tells an add, a decrement and a removal apart, and `0` marks the
  /// first add — the one that gets the confirmation sheet instead of a toast.
  ///
  /// With the cart not loaded yet it reads `0`, so an add reads as a first one
  /// — which is what it almost always is.
  int get previousQuantity => _previousQuantity;

  /// Whether the update that just settled put this product in the cart for the
  /// first time, rather than changing a line that was already there.
  bool get joinedCart => _previousQuantity == 0;

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

  /// Sets a cart line to [productQuantity]; `0` removes it. [productId] is the
  /// line's product (the request path) and [cartItemId] the line itself (the
  /// query) — passed in rather than read off the lane id, which for a cart line
  /// is the `cart_item_id`, not the product id.
  ///
  /// [seededQuantity]: what the caller can already see this line's quantity to
  /// be — see [_send].
  Future<void> updateCartProductQuantity(
    int productQuantity, {
    required int productId,
    int? cartItemId,
    int? seededQuantity,
  }) => _send(
    () => _repo.updateCartProductQuantity(
      productId,
      productQuantity,
      cartItemId: cartItemId,
    ),
    productId: productId,
    seededQuantity: seededQuantity,
  );

  /// Puts [productQuantity] of this product in the cart, with the selected
  /// product [options] when the product has any. The lane id is the product id
  /// here — an add has no line yet.
  Future<void> addToCart(
    int productQuantity, {
    Map<String, dynamic>? options,
    int? seededQuantity,
  }) => _send(
    () => _repo.addToCart(_laneId, productQuantity, options),
    productId: _laneId,
    seededQuantity: seededQuantity,
  );

  /// Fires [request] and, on success, records what this product's quantity was
  /// beforehand, which is what tells an add from a change.
  ///
  /// The shared cart is the best answer whenever it is loaded. When it is not —
  /// a guest, or a signed-in user during the window the boot fetch is still in
  /// flight — [seededQuantity] stands in: the quantity the calling card was
  /// rendered with, which came from the listing payload. Without it every
  /// increment read as `0` and was answered with the "added to cart" sheet
  /// instead of a quiet toast.
  Future<void> _send(
    Future<Either<Failure, CartModel>> Function() request, {
    required int productId,
    int? seededQuantity,
  }) async {
    // Captured before the request, not after it: a sibling update of the same
    // product can refresh the shared cart while this one is still in flight.
    final int? cachedQuantity = _ref
        .read(getCartProvider)
        .valueOrNull
        ?.quantityOf(productId);

    state = const AsyncValue<CartModel?>.loading();

    final Either<Failure, CartModel> result = await request();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue<CartModel?>.error(failure.message, StackTrace.current),
      (CartModel cart) {
        _previousQuantity = cachedQuantity ?? seededQuantity ?? 0;
        _feedbackPending = true;
        _ref.read(getCartProvider.notifier).updateCartState(cart);
        return AsyncValue<CartModel?>.data(cart);
      },
    );
  }
}
