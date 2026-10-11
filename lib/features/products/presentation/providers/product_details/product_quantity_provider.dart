import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_model_provider.dart';

final productQuantityProvider = StateProvider.autoDispose<int>((ref) => 1);

/// How many more units of the product on screen the cart can take: its stock
/// less what the live cart already holds. `null` = no cap.
final productRemainingProvider = Provider.autoDispose<int?>((Ref ref) {
  final ProductModel product = ref.watch(productProvider);
  final int? id = product.id;
  final int inCart = id == null
      ? 0
      : ref.watch(
          getCartProvider.select(
            (AsyncValue<CartModel> cart) =>
                cart.valueOrNull?.quantityOf(id) ?? 0,
          ),
        );
  return remainingStock(product.stock, inCart);
}, dependencies: <ProviderOrFamily>[productProvider]);

/// [stock] less the [inCart] units, never below 0. A `null` stock means the
/// server sent none: no cap, as on the product cards.
int? remainingStock(int? stock, int inCart) =>
    stock == null ? null : math.max(0, stock - inCart);

/// The stepper's [wanted] quantity, kept within [remaining].
int stepperQuantity(int wanted, int? remaining) =>
    remaining == null || remaining < 1 ? wanted : math.min(wanted, remaining);
