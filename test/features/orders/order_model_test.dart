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
      'items': <Map<String, dynamic>>[_line(id: 1, quantity: 2, unitPrice: 10)],
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

  // Store invoice: 100 − 10 discount + 13.5 VAT + 15 delivery = 118.5.
  Map<String, dynamic> invoice({required double total, double tip = 0}) =>
      <String, dynamic>{
        'subtotal': 100,
        'discount_amount': 10,
        'tax_amount': 13.5,
        'delivery_fee': 15,
        'driver_tip': tip,
        'total_amount': total,
      };

  test('Total adds the tip the backend keeps outside total_amount', () {
    expect(
      OrderModel.fromJson(invoice(total: 118.5, tip: 5)).totalWithTip,
      123.5,
    );
  });

  test('Total does not add the tip twice on an older order that holds it', () {
    expect(
      OrderModel.fromJson(invoice(total: 123.5, tip: 5)).totalWithTip,
      123.5,
    );
  });

  test('Total is total_amount when there is no tip', () {
    expect(OrderModel.fromJson(invoice(total: 118.5)).totalWithTip, 118.5);
  });

  test(
    'the invoice total leaves the tip out, wherever total_amount keeps it',
    () {
      expect(
        OrderModel.fromJson(invoice(total: 118.5, tip: 5)).invoiceTotal,
        118.5,
      );
      expect(
        OrderModel.fromJson(invoice(total: 123.5, tip: 5)).invoiceTotal,
        118.5,
      );
      expect(OrderModel.fromJson(invoice(total: 118.5)).invoiceTotal, 118.5);
    },
  );

  test('the voucher share is taken out of the discount row', () {
    final OrderModel order = OrderModel.fromJson(<String, dynamic>{
      'discount_amount': 15.3,
      'voucher': <String, dynamic>{'code': 'GIFT10', 'discount_applied': 10.2},
    });

    expect(order.voucherCode, 'GIFT10');
    expect(order.voucherDiscount, 10.2);
    expect(order.couponDiscount, 5.1);
  });

  test('support is hidden only for closed and cancelled orders', () {
    OrderModel orderWithStatus(String status, {String? deliveredAt}) =>
        OrderModel.fromJson(<String, dynamic>{
          'status': status,
          'delivered_at': deliveredAt,
        });

    expect(orderWithStatus('pending').canContactSupport, isTrue);
    expect(orderWithStatus('delivered').canContactSupport, isTrue);
    expect(
      orderWithStatus('closed', deliveredAt: '2026-10-14').canContactSupport,
      isFalse,
    );
    expect(orderWithStatus('closed').canContactSupport, isFalse);
    expect(orderWithStatus('cancelled').canContactSupport, isFalse);
    expect(orderWithStatus('rejected').canContactSupport, isFalse);
  });

  test('return states get a real label and lines carry returned units', () {
    final OrderModel order = OrderModel.fromJson(<String, dynamic>{
      'status': 'partially_returned',
      'items': <Map<String, dynamic>>[
        <String, dynamic>{
          'product_name': 'Milk',
          'quantity': 3,
          'returned_quantity': 1,
          'unit_price': 5,
        },
      ],
    });

    expect(order.orderStatus, <String, dynamic>{
      'ar': 'مرتجع جزئيًا',
      'en': 'Partially returned',
    });
    expect(order.items.single.returnedQuantity, 1);
    expect(
      OrderModel.fromJson(<String, dynamic>{'status': 'returned'}).orderStatus,
      <String, dynamic>{'ar': 'مرتجع', 'en': 'Returned'},
    );
  });

  test('an order with a complaint on file says so', () {
    final OrderModel order = OrderModel.fromJson(<String, dynamic>{
      'status': 'delivered',
      'complaint': <String, dynamic>{'id': 42, 'status': 'under_review'},
    });

    expect(order.hasComplaint, isTrue);
    expect(order.complaintId, 42);
    expect(order.complaintStatus, 'under_review');
  });

  test('a null or missing complaint means none was filed', () {
    expect(
      OrderModel.fromJson(<String, dynamic>{'complaint': null}).hasComplaint,
      isFalse,
    );
    expect(OrderModel.fromJson(<String, dynamic>{}).hasComplaint, isFalse);
  });
}
