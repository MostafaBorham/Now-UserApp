import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_add_to_cart_button.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_counter_view.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/update_cart_product_vm.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';






























class AnimatedCartButton extends ConsumerStatefulWidget {
  const AnimatedCartButton({
    super.key,
    this.productId,
    this.productQuantity = 0,
    this.stock,
  });




  final int? productId;



  final int? productQuantity;



  final int? stock;

  @override
  ConsumerState<AnimatedCartButton> createState() => _AnimatedCartButtonState();
}

class _AnimatedCartButtonState extends ConsumerState<AnimatedCartButton> {



  late int _counter = widget.productQuantity ?? 0;

  bool _showCounterView = false;
  bool _isRotate = false;
  Timer? _collapseTimer;

  bool get _isIntegrated => widget.productId != null;









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



      cart = ref.watch(getCartProvider).valueOrNull;
    }

    final int counter = _quantityFrom(cart);

    final bool showCounterView =
        _showCounterView && (isUpdating || counter > 0);



    final bool canIncrement = widget.stock == null || counter < widget.stock!;



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

                setState(() => _showCounterView = true);







                if (counter < 1) {
                  canIncrement ? _updateQuantity(1) : _collapse();
                } else {
                  _startCollapseTimer();
                }
              },
            ),
          );
  }




  void _decrement(int counter) => _updateQuantity(counter > 1 ? counter - 1 : 1);




  void _updateQuantity(int newQuantity) {
    if (!_isIntegrated) {
      setState(() => _counter = newQuantity);
      newQuantity < 1 ? _collapse() : _startCollapseTimer();
      return;
    }


    _collapseTimer?.cancel();

    ref
        .read(updateCartProductProvider(widget.productId!).notifier)
        .updateCartProductQuantity(newQuantity);
  }









  void _onUpdateStateChanged(AsyncValue<CartModel?> state) {
    state.whenOrNull(
      data: (CartModel? cart) {

        if (cart == null) return;

        final int newQuantity = _quantityOf(cart);
        newQuantity < 1 ? _collapse() : _startCollapseTimer();
      },
      error: (Object error, StackTrace _) {
        if (!mounted) return;

        AppToast.showError(context, error.toString());





        final int current = _quantityFrom(ref.read(getCartProvider).valueOrNull);
        current < 1 ? _collapse() : _startCollapseTimer();
      },
    );
  }




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
