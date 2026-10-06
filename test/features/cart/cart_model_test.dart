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

  test('sums a product\'s variant lines (BUG-022, QA V2)', () {
    final CartModel cart = _cartOf(<ProductModel>[
      const ProductModel(productId: 7, cartItemId: 1, quantity: 2),
      const ProductModel(productId: 8, cartItemId: 2, quantity: 4),
      const ProductModel(productId: 7, cartItemId: 3, quantity: 3),
    ]);

    expect(cart.quantityOf(7), 5);
    expect(cart.linesOf(7).map((ProductModel l) => l.cartItemId), <int>[1, 3]);
    expect(cart.lineOf(7)?.cartItemId, 1);
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

  test('itemCount sums quantities across every vendor line', () {
    const CartModel cart = CartModel(
      vendors: <CartVendorModel>[
        CartVendorModel(
          products: <ProductModel>[
            ProductModel(productId: 1, quantity: 2),
            ProductModel(productId: 2, quantity: 3),
          ],
        ),
        CartVendorModel(
          products: <ProductModel>[ProductModel(productId: 3, quantity: 5)],
        ),
      ],
    );

    expect(cart.itemCount, 10);
    // A missing quantity counts as 0, and an empty cart is 0.
    expect(
      _cartOf(<ProductModel>[const ProductModel(productId: 9)]).itemCount,
      0,
    );
    expect(const CartModel().itemCount, 0);
  });

  test('parses cart_item_id and the raw options off a cart line', () {
    final ProductModel line = ProductModel.fromJson(<String, dynamic>{
      'product_id': 7,
      'cart_item_id': 64,
      'quantity': 2,
      'options': <String, dynamic>{
        'color': '#9CA3AF',
        'attributes': <dynamic>[
          <String, dynamic>{
            'attribute_name': <String, dynamic>{'ar': 'المقاس', 'en': 'Size'},
            'values': <dynamic>[
              <String, dynamic>{
                'id': 64,
                'name': <String, dynamic>{'ar': 'وسط', 'en': 'Medium'},
              },
            ],
          },
        ],
      },
    });

    expect(line.cartItemId, 64);
    expect(line.options?['color'], '#9CA3AF');
    expect((line.options?['attributes'] as List).length, 1);
  });
}
