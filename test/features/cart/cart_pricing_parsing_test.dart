import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';

/// `min_order_value` used to be assigned straight into a `double` field with no
/// conversion, so a server sending a whole number (`100`, not `100.0`) threw
/// `type 'int' is not a subtype of type 'double'` out of `fromJson`. The repo's
/// catch-all turned that into the cart's error message, so the shopper got a
/// raw Dart type error in place of their cart.
void main() {
  group('CartVendorPricingModel.fromJson min_order_value', () {
    test('accepts a whole number', () {
      expect(
        CartVendorPricingModel.fromJson(<String, dynamic>{
          'min_order_value': 100,
        }).minOrderValue,
        100.0,
      );
    });

    test('accepts a decimal', () {
      expect(
        CartVendorPricingModel.fromJson(<String, dynamic>{
          'min_order_value': 99.5,
        }).minOrderValue,
        99.5,
      );
    });

    test('falls back to 0 when missing or not a number', () {
      expect(
        CartVendorPricingModel.fromJson(<String, dynamic>{}).minOrderValue,
        0,
      );
      expect(
        CartVendorPricingModel.fromJson(<String, dynamic>{
          'min_order_value': null,
        }).minOrderValue,
        0,
      );
      expect(CartVendorPricingModel.fromJson(null).minOrderValue, 0);
    });
  });

  group('CartVendorPricingModel.fromJson money fields', () {
    test('reads numbers and numeric strings alike', () {
      final CartVendorPricingModel pricing =
          CartVendorPricingModel.fromJson(<String, dynamic>{
            'subtotal': '120.50',
            'tax': 6,
            'delivery_fee': 10.0,
            'discount': '0',
            'total': 136.5,
            'available': true,
            'min_order_met': true,
          });

      expect(pricing.subtotal, 120.5);
      expect(pricing.tax, 6.0);
      expect(pricing.deliveryFee, 10.0);
      expect(pricing.discount, 0.0);
      expect(pricing.total, 136.5);
      expect(pricing.available, isTrue);
      expect(pricing.minOrderMet, isTrue);
    });

    test('defaults the flags to blocking rather than permissive', () {
      const CartVendorPricingModel pricing = CartVendorPricingModel();

      expect(pricing.available, isFalse);
      expect(pricing.minOrderMet, isFalse);
    });
  });

  group('CartModel.fromJson', () {
    test('survives a null, empty or vendor-less payload', () {
      expect(CartModel.fromJson(null).vendors, isEmpty);
      expect(CartModel.fromJson(<String, dynamic>{}).vendors, isEmpty);
      expect(
        CartModel.fromJson(<String, dynamic>{
          'cart': <String, dynamic>{'id': 4},
        }).vendors,
        isEmpty,
      );
    });

    test('reads the vendor, its lines and its pricing', () {
      final CartModel cart = CartModel.fromJson(<String, dynamic>{
        'cart': <String, dynamic>{
          'id': 12,
          'vendors': <dynamic>[
            <String, dynamic>{
              'vendor': <String, dynamic>{'id': 3, 'name': 'Panda'},
              'products': <dynamic>[
                <String, dynamic>{'product_id': 7, 'quantity': 2},
              ],
              'pricing': <String, dynamic>{'min_order_value': 50, 'total': 80},
            },
          ],
        },
      });

      expect(cart.id, 12);
      expect(cart.vendors.single.vendor.id, 3);
      expect(cart.vendors.single.pricing.minOrderValue, 50.0);
      expect(cart.quantityOf(7), 2);
    });
  });
}
