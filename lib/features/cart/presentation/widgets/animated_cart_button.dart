import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/dialogs/app_custom_alert_dialog.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart_stepper_pill.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart_update_feedback.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/update_cart_product_vm.dart';

/// Cart control shown on a product card: a round add-to-cart button that grows
/// into a quantity pill and back (see [CartStepperPill] for the visuals).
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
///
/// A product in the cart as several variant lines shows their total, and a tap
/// opens its product page (or the cart, without a [productSlug]) instead of
/// the counter: a card can't tell which line a +/- is for, and the server
/// refused the line-less update with a 422.
class AnimatedCartButton extends ConsumerStatefulWidget {
  const AnimatedCartButton({
    super.key,
    this.productId,
    this.productSlug,
    this.productQuantity = 0,
    this.stock,
  });

  /// Product this control manages in the cart. `null` disables backend
  /// integration.
  final int? productId;

  /// Opens the product page when the product has several cart lines.
  final String? productSlug;

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

  /// Tapped open: the pill is growing, and [_onPillSettled] then opens the
  /// counter.
  bool _isOpening = false;
  Timer? _collapseTimer;

  bool get _isIntegrated => widget.productId != null;

  /// The quantity to display.
  ///
  /// Integrated cards read it from the shared cart ([getCartProvider]) — the
  /// single source of truth that survives the card scrolling out of the list
  /// and back, so a change made here is no longer lost on rebuild. Until the
  /// cart is first loaded ([cartQuantity] is `null`) the listing seed
  /// ([AnimatedCartButton.productQuantity]) stands in, which is itself the cart
  /// quantity at list-fetch time. Non-integrated cards count locally.
  int _quantityFrom(int? cartQuantity) {
    if (!_isIntegrated) return _counter;
    return cartQuantity ?? widget.productQuantity ?? 0;
  }

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isUpdating = false;
    int? cartQuantity;

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
      // a change survives the card scrolling out of the list and back. Only
      // this product's quantity is watched: Home mounts dozens of these, and
      // watching the whole cart rebuilt every one of them on any cart change.
      final int productId = widget.productId!;
      cartQuantity = ref.watch(
        getCartProvider.select(
          (AsyncValue<CartModel> cart) =>
              cart.valueOrNull?.quantityOf(productId),
        ),
      );
    }

    final int counter = _quantityFrom(cartQuantity);

    final bool showCounterView =
        _showCounterView && (isUpdating || counter > 0);

    // The counter never climbs past the available stock; a null stock leaves it
    // uncapped.
    final bool canIncrement = widget.stock == null || counter < widget.stock!;

    // The pill grows toward the start from the card's corner; the card only
    // has to anchor it there.
    return CartStepperPill(
      expanded: showCounterView || (_isOpening && !_showCounterView),
      counter: counter,
      isLoading: isUpdating,
      canIncrement: canIncrement,
      onTap: () {
        if (_hasSeveralLines()) {
          _openProduct();
          return;
        }
        setState(() => _isOpening = true);
      },
      onInc: () => _updateQuantity(counter + 1),
      onDec: () => _decrement(counter),
      onDelete: _confirmRemove,
      onAnimationEnd: () => _onPillSettled(counter, canIncrement),
    );
  }

  /// The pill finished growing (or shrinking). Grown from a tap, it opens the
  /// counter.
  void _onPillSettled(int counter, bool canIncrement) {
    if (!_isOpening || _showCounterView) return;
    setState(() => _showCounterView = true);

    // The button doubles as the add-to-cart action only while the product is
    // not in the cart yet — a single tap is then already an add. With units
    // already in the cart it only reveals the counter, and the request is left
    // to the counter's own icons.
    if (counter >= 1) {
      _startCollapseTimer();
      return;
    }

    if (canIncrement) {
      _updateQuantity(1);
      return;
    }

    // Nothing left to add. This used to open and collapse again in silence,
    // which reads as a dead button — say why.
    AppToast.showError(context, LangKeys.outOfStockKey.tr());
    _collapse();
  }

  /// This product's cart lines, one per variant it is in the cart with.
  List<ProductModel> _lines() =>
      ref.read(getCartProvider).valueOrNull?.linesOf(widget.productId!) ??
      const <ProductModel>[];

  bool _hasSeveralLines() => _isIntegrated && _lines().length > 1;

  /// Where several variant lines are told apart: the product page, or the
  /// cart when the card has no slug to open it by.
  void _openProduct() {
    final String? slug = widget.productSlug;
    if (slug == null || slug.isEmpty) {
      openMainCartTab(context, ref);
      return;
    }
    context.pushNamed(AppRoutes.productDetailsScreen, extra: slug);
  }

  /// One unit less than [counter], floored at 1 — dropping the last unit is the
  /// delete icon's job. The counter view only offers this icon from 2 upwards
  /// anyway, so the floor is just a safety net.
  void _decrement(int counter) =>
      _updateQuantity(counter > 1 ? counter - 1 : 1);

  /// Asks before dropping the last unit, matching the cart screen's own
  /// stepper — a removal is not something to do on a mistaken tap.
  ///
  /// Local-only cards ([_isIntegrated] false) have nothing on the server to
  /// remove, so they just reset.
  void _confirmRemove() {
    if (!_isIntegrated) {
      _updateQuantity(0);
      return;
    }

    // The counter must stay open behind the dialog, or confirming would leave
    // nothing to report back to.
    _collapseTimer?.cancel();

    AppCustomAlertDialog.show(
      context,
      (BuildContext dialogContext) => AppCustomAlertDialog(
        title: LangKeys.removeItemFromCartKey.tr(),
        message: LangKeys.removeItemFromCartConfirmationKey.tr(),
        confirmLabel: LangKeys.deleteKey.tr(),
        onConfirm: () {
          dialogContext.pop();
          _updateQuantity(0);
        },
      ),
    ).then((_) {
      // Dismissed without confirming: let the counter go back to idling shut.
      if (mounted) _startCollapseTimer();
    });
  }

  /// Asks the server to set this product's cart line to [newQuantity] (`0`
  /// removes it). The counter is deliberately left untouched — it only moves
  /// once the response settles, so a failure needs no revert.
  void _updateQuantity(int newQuantity) {
    if (!_isIntegrated) {
      setState(() => _counter = newQuantity);
      newQuantity < 1 ? _collapse() : _startCollapseTimer();
      return;
    }

    // A second variant can land (from the product page) while the counter is
    // open; which line a +/- is for is then unknown.
    final List<ProductModel> lines = _lines();
    if (lines.length > 1) {
      _collapse();
      _openProduct();
      return;
    }

    // The counter view has to stay open until the request settles.
    _collapseTimer?.cancel();

    ref
        .read(updateCartProductProvider(widget.productId!).notifier)
        .updateCartProductQuantity(
          newQuantity,
          productId: widget.productId!,
          // The one line the product has, so the server needn't guess.
          cartItemId: lines.firstOrNull?.cartItemId,
          seededQuantity: widget.productQuantity,
        );
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

        if (mounted) {
          showCartUpdateFeedback(
            context,
            ref,
            productId: widget.productId!,
            cart: cart,
          );
        }

        final int newQuantity = cart.quantityOf(widget.productId!);
        newQuantity < 1 ? _collapse() : _startCollapseTimer();
      },
      error: (Object error, StackTrace _) {
        if (!mounted) return;

        AppToast.showError(context, error.toString());

        // A failure leaves the cart untouched, so fall back to the last
        // confirmed quantity. Same rule as a success: with no quantity left to
        // show there is no point keeping the counter open — e.g. a failed first
        // add, where the quantity is still 0.
        final int current = _quantityFrom(
          ref.read(getCartProvider).valueOrNull?.quantityOf(widget.productId!),
        );
        current < 1 ? _collapse() : _startCollapseTimer();
      },
    );
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
      _isOpening = false;
    });
  }
}
