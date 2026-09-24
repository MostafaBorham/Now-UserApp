import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';

/// One `OrderItemResource` line as `GET /my/orders/{uuid}` sends it, with the
/// nested product at today's catalogue price.
Map<String, dynamic> _line({
  required int id,
  required int quantity,
  required double unitPrice,
  bool unavailable = false,
}) => <String, dynamic>{
  'id': id,
  'product_id': id,
  'product_name': 'P$id',
  'quantity': quantity,
  'unit_price': unitPrice,
  'total_price': unitPrice * quantity,
  'is_unavailable': unavailable,
  'product': <String, dynamic>{
    'id': id,
    'name': <String, String>{'ar': 'م$id', 'en': 'P$id'},
    'price': 99.0,
  },
};

void main() {
  test('a line shows what was paid, not what the product costs today', () {
    final OrderModel order = OrderModel.fromJson(<String, dynamic>{
      'items': <Map<String, dynamic>>[
        _line(id: 1, quantity: 2, unitPrice: 10),
      ],
    });

    expect(order.items.single.price, 10);
    expect(order.items.single.quantity, 2);
  });

  test('a line the vendor refused is kept apart and not counted', () {
    final OrderModel order = OrderModel.fromJson(<String, dynamic>{
      'items': <Map<String, dynamic>>[
        _line(id: 1, quantity: 2, unitPrice: 10),
        _line(id: 2, quantity: 3, unitPrice: 5),
        _line(id: 3, quantity: 1, unitPrice: 7, unavailable: true),
      ],
    });

    expect(order.items.map((ProductModel p) => p.id), <int>[1, 2]);
    expect(order.unavailableItems.map((ProductModel p) => p.id), <int>[3]);
    expect(order.itemsQuantity, 5);
  });

  test('a flat line (no nested product) still reads its paid price', () {
    final OrderModel order = OrderModel.fromJson(<String, dynamic>{
      'items': <Map<String, dynamic>>[
        <String, dynamic>{
          'product_id': 4,
          'product_name': 'Tea',
          'quantity': 1,
          'unit_price': 12.5,
        },
      ],
    });

    expect(order.items.single.price, 12.5);
  });
}
