import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/data/repo/cart_repo.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';

/// The cart tab refreshes quietly every time it opens, so a refresh is often in
/// flight while the shopper edits a line. Its answer was fetched before that
/// edit and must not overwrite it.
void main() {
  CartModel cartWith(int quantity) => CartModel(
    vendors: <CartVendorModel>[
      CartVendorModel(
        products: <ProductModel>[
          ProductModel(productId: 7, quantity: quantity),
        ],
      ),
    ],
  );

  test(
    'a refresh answered after a mutation leaves the mutation on screen',
    () async {
      final Completer<Either<Failure, CartModel>> fetch =
          Completer<Either<Failure, CartModel>>();
      final GetCartViewModel vm = GetCartViewModel(
        AsyncValue<CartModel>.data(cartWith(1)),
        repo: _PendingCartRepo(fetch.future),
      );

      final Future<String?> refreshing = vm.refresh();
      vm.updateCartState(cartWith(3));
      fetch.complete(Right<Failure, CartModel>(cartWith(2)));

      expect(await refreshing, isNull);
      expect(vm.state.value!.quantityOf(7), 3);
      vm.dispose();
    },
  );

  test('a failed refresh keeps the loaded cart and reports why', () async {
    final GetCartViewModel vm = GetCartViewModel(
      AsyncValue<CartModel>.data(cartWith(1)),
      repo: _PendingCartRepo(
        Future<Either<Failure, CartModel>>.value(
          const Left<Failure, CartModel>(Failure('offline')),
        ),
      ),
    );

    expect(await vm.refresh(), 'offline');
    expect(vm.state.value!.quantityOf(7), 1);
    vm.dispose();
  });
}

class _PendingCartRepo extends Fake implements CartRepo {
  _PendingCartRepo(this._answer);

  final Future<Either<Failure, CartModel>> _answer;

  @override
  Future<Either<Failure, CartModel>> getCart() => _answer;

  @override
  void cancelRequests() {}
}
