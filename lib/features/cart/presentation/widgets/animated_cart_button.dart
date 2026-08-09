import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_add_to_cart_button.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_counter_view.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/update_cart_product_vm.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';

/// Cart control shown on a product card: a round add-to-cart button that flips
/// into a quantity counter and back.
///
/// Pass [productId] together with [productQuantity] to wire the counter to
/// `updateCartProductProvider(productId)`. Exactly three interactions reach the
/// server: the add-to-cart button **while the product is not in the cart yet**
/// (it sends the first unit; with units already in the cart it only opens the
/// counter), and the counter's own increment / decrement and delete icons.
/// Decrement floors at 1, so the only way down to 0 is the delete icon (which the
/// counter view shows in place of the decrement icon while a single unit is
/// left). The three response states then drive the view:
/// - **loading** — the counter view stays open, its number is replaced by a
///   spinner and all three icons stop responding,
/// - **error** — the number keeps the last quantity the server confirmed and the
///   message is surfaced in a snackbar,
/// - **data** — the number takes the quantity the fresh cart reports, then the
///   counter view collapses back to the add-to-cart button (immediately when the
///   line is gone, after a short grace period otherwise so the user can keep
///   tapping).
///
/// A `0` is never shown in the counter: whenever the quantity reaches zero — a
/// delete, or a failed first add — the counter view is hidden and the
/// add-to-cart button (back to `+`) takes over.
///
/// Because the counter only ever moves on a confirmed response there is nothing
/// to revert on failure — no optimistic quantity is ever shown.
///
/// With [productId] left `null` the widget keeps its offline behaviour and just
/// counts locally (used by the cards that are still on placeholder data).
class AnimatedCartButton extends ConsumerStatefulWidget {
  const AnimatedCartButton({
    super.key,
    this.productId,
    this.productQuantity = 0,
    this.stock,
  });


  /// Product this control manages in the cart. `null` disables backend
  /// integration.
  final int? productId;

  /// Quantity this product currently has in the cart — `0` when it is not in the
  /// cart at all. Seeds the counter.
  final int? productQuantity;

  /// Available stock for this product — the counter never climbs past it. `null`
  /// leaves the counter uncapped (used by cards still on placeholder data).
  final int? stock;

  @override
  ConsumerState<AnimatedCartButton> createState() => _AnimatedCartButtonState();
}

class _AnimatedCartButtonState extends ConsumerState<AnimatedCartButton> {
  /// Local-only quantity for non-integrated cards (no [productId]): the last
  /// value a local tap set. Integrated cards ignore this and read their
  /// quantity from the shared cart instead — see [_quantityFrom].
  late int _counter = widget.productQuantity ?? 0;

  bool _showCounterView = false;
  bool _isRotate = false;
  Timer? _collapseTimer;

  bool get _isIntegrated => widget.productId != null;

  /// The quantity to display.
  ///
  /// Integrated cards read it from the shared cart ([getCartProvider]) — the
  /// single source of truth that survives the card scrolling out of the list
  /// and back, so a change made here is no longer lost on rebuild. Until the
  /// cart is first loaded ([cart] is `null`) the listing seed
  /// ([AnimatedCartButton.productQuantity]) stands in, which is itself the cart
  /// quantity at list-fetch time. Non-integrated cards count locally.
  int _quantityFrom(CartModel? cart) {
    if (!_isIntegrated) return _counter;
    if (cart == null) return widget.productQuantity ?? 0;
    return _quantityOf(cart);
  }

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isUpdating = false;
    CartModel? cart;

    if (_isIntegrated) {
      final AutoDisposeStateNotifierProvider<
        UpdateCartProductViewModel,
        AsyncValue<CartModel?>
      >
      provider = updateCartProductProvider(widget.productId!);

      ref.listen<AsyncValue<CartModel?>>(
        provider,
        (AsyncValue<CartModel?>? previous, AsyncValue<CartModel?> next) =>
            _onUpdateStateChanged(next),
      );
      isUpdating = ref.watch(provider).isLoading;

      // The shared cart is the source of truth for this product's quantity, so
      // a change survives the card scrolling out of the list and back.
      cart = ref.watch(getCartProvider).valueOrNull;
    }

    final int counter = _quantityFrom(cart);

    final bool showCounterView =
        _showCounterView && (isUpdating || counter > 0);

    // The counter never climbs past the available stock; a null stock leaves it
    // uncapped.
    final bool canIncrement = widget.stock == null || counter < widget.stock!;

    // Both children size themselves naturally — it is up to the card to give
    // this control a stable slot to flip inside of.
    return showCounterView
        ? AnimatedCartCounterView(
            counter: counter,
            isLoading: isUpdating,
            canIncrement: canIncrement,
            onInc: canIncrement ? () => _updateQuantity(counter + 1) : null,
            onDec: () => _decrement(counter),
            onDelete: () => _updateQuantity(0),
          )
        : InkWell(
            onTap: () => setState(() => _isRotate = !_isRotate),
            child: AnimatedAddToCartButton(
              text: counter < 1 ? '+' : counter.toString(),
              isRotate: _isRotate,
              onEnd: () {
                // The rotation has finished: open the counter.
                setState(() => _showCounterView = true);

                // The button doubles as the add-to-cart action only while
                // the product is not in the cart yet — a single tap is then
                // already an add. With units already in the cart it only
                // reveals the counter, and the request is left to the
                // counter's own icons. With no stock left there is nothing to
                // add, so the counter just collapses back to the button.
                if (counter < 1) {
                  canIncrement ? _updateQuantity(1) : _collapse();
                } else {
                  _startCollapseTimer();
                }
              },
            ),
          );
  }

  /// One unit less than [counter], floored at 1 — dropping the last unit is the
  /// delete icon's job. The counter view only offers this icon from 2 upwards
  /// anyway, so the floor is just a safety net.
  void _decrement(int counter) => _updateQuantity(counter > 1 ? counter - 1 : 1);

  /// Asks the server to set this product's cart line to [newQuantity] (`0`
  /// removes it). The counter is deliberately left untouched — it only moves
  /// once the response settles, so a failure needs no revert.
  void _updateQuantity(int newQuantity) {
    if (!_isIntegrated) {
      setState(() => _counter = newQuantity);
      newQuantity < 1 ? _collapse() : _startCollapseTimer();
      return;
    }

    // The counter view has to stay open until the request settles.
    _collapseTimer?.cancel();

    ref
        .read(updateCartProductProvider(widget.productId!).notifier)
        .updateCartProductQuantity(newQuantity);
  }

  /// Applies a settled update: a success collapses the counter (or keeps it open
  /// briefly) based on the quantity the fresh cart reports, a failure only
  /// surfaces its message and leaves the quantity where it was.
  ///
  /// The displayed number is not touched here — the counter is driven straight
  /// off the shared cart in [build], which the VM already refreshed before
  /// emitting this state. This callback only decides whether the counter view
  /// stays open.
  void _onUpdateStateChanged(AsyncValue<CartModel?> state) {
    state.whenOrNull(
      data: (CartModel? cart) {
        // The idle seed of the viewmodel, not a response.
        if (cart == null) return;

        final int newQuantity = _quantityOf(cart);
        newQuantity < 1 ? _collapse() : _startCollapseTimer();
      },
      error: (Object error, StackTrace _) {
        if (!mounted) return;

        ErrorSnackBar.show(context, error.toString());

        // A failure leaves the cart untouched, so fall back to the last
        // confirmed quantity. Same rule as a success: with no quantity left to
        // show there is no point keeping the counter open — e.g. a failed first
        // add, where the quantity is still 0.
        final int current = _quantityFrom(ref.read(getCartProvider).valueOrNull);
        current < 1 ? _collapse() : _startCollapseTimer();
      },
    );
  }

  /// Reads this product's quantity out of [cart]; `0` when the line is no longer
  /// there (it was removed). Cart lines carry the product id in `product_id`,
  /// while listing products carry it in `id` — match either.
  int _quantityOf(CartModel cart) {
    for (final CartVendorModel vendor in cart.vendors) {
      for (final ProductModel product in vendor.products) {
        if ((product.productId ?? product.id) == widget.productId) {
          return product.quantity ?? 0;
        }
      }
    }

    return 0;
  }

  /// Collapses the counter view back to the add-to-cart button after a short
  /// idle period, restarted by every interaction so a burst of taps keeps it
  /// open.
  void _startCollapseTimer() {
    _collapseTimer?.cancel();
    _collapseTimer = Timer(const Duration(seconds: 2), _collapse);
  }

  void _collapse() {
    _collapseTimer?.cancel();

    if (!mounted) return;

    setState(() {
      _showCounterView = false;
      _isRotate = false;
    });
  }
}
