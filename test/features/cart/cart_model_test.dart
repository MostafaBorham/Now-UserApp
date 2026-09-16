import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';

/// Cart lines carry the product id in `product_id`, listing products in `id`.
/// Getting this wrong reads every product as absent from the cart, which is
/// what tells an add apart from a quantity change — so it would answer every
/// tap with the "added to cart" sheet.
CartModel _cartOf(List<ProductModel> products) =>
    CartModel(vendors: <CartVendorModel>[CartVendorModel(products: products)]);

void main() {
  test('finds a line by product_id', () {
    final CartModel cart = _cartOf(<ProductModel>[
      const ProductModel(id: 99, productId: 7, quantity: 3),
    ]);

    expect(cart.quantityOf(7), 3);
    expect(cart.lineOf(7)?.productId, 7);
  });

  test('falls back to id when the line carries no product_id', () {
    final CartModel cart = _cartOf(<ProductModel>[
      const ProductModel(id: 7, quantity: 2),
    ]);

    expect(cart.quantityOf(7), 2);
  });

  test('reports 0 for a product the cart has no line for', () {
    final CartModel cart = _cartOf(<ProductModel>[
      const ProductModel(id: 99, productId: 7, quantity: 3),
    ]);

    expect(cart.quantityOf(1), 0);
    expect(cart.lineOf(1), isNull);
    expect(const CartModel().quantityOf(7), 0);
  });

  test('searches across vendors', () {
    const CartModel cart = CartModel(
      vendors: <CartVendorModel>[
        CartVendorModel(
          products: <ProductModel>[ProductModel(productId: 1, quantity: 1)],
        ),
        CartVendorModel(
          products: <ProductModel>[ProductModel(productId: 2, quantity: 5)],
        ),
      ],
    );

    expect(cart.quantityOf(2), 5);
  });
}
