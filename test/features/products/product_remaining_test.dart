import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_model_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_quantity_provider.dart';

// BUG-026/027: the product page capped its stepper at the bare stock (and at 1
// for a null stock) and never looked at what the cart already held.
void main() {
  int? remaining({int? stock, int inCart = 0}) {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        productProvider.overrideWithValue(ProductModel(id: 7, stock: stock)),
        getCartProvider.overrideWith(
          (Ref ref) => GetCartViewModel(
            AsyncValue<CartModel>.data(
              CartModel(
                vendors: <CartVendorModel>[
                  CartVendorModel(
                    products: <ProductModel>[
                      ProductModel(id: 7, quantity: inCart),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container.read(productRemainingProvider);
  }

  test('stock less what the cart already holds', () {
    expect(remaining(stock: 5, inCart: 2), 3);
    expect(remaining(stock: 5, inCart: 5), 0);
    expect(remaining(stock: 5, inCart: 9), 0);
  });

  test('a null stock is no cap', () {
    expect(remaining(inCart: 3), isNull);
  });

  test('the stepper is clamped to what remains', () {
    expect(stepperQuantity(4, 3), 3);
    expect(stepperQuantity(2, 3), 2);
    expect(stepperQuantity(9, null), 9);
    // Nothing left: the buttons are disabled, the stepper keeps its value.
    expect(stepperQuantity(1, 0), 1);
  });
}
