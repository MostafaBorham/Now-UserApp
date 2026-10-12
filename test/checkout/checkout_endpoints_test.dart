import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/checkout/data/datasources/remote/api/checkout_endpoints.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';

// Pins the place/preview request to the backend's rules
// (`Place{Cart,Vendor}CheckoutRequest`): a key the server doesn't read is
// silently dropped, and that is how coupons and vouchers were never applied.
void main() {
  const List<AppliedDiscountModel> discounts = <AppliedDiscountModel>[
    AppliedDiscountModel(vendorId: 9, code: 'NINE'),
    AppliedDiscountModel(vendorId: 2, code: 'TWO'),
    AppliedDiscountModel(vendorId: 5, code: 'VCH-000001', isVoucher: true),
  ];

  test('a single store places through its own endpoint, never the cart', () {
    expect(CheckoutEndpoints.place(7), '/api/v1/checkout/vendor/7');
    expect(CheckoutEndpoints.place(null), '/api/v1/checkout/cart');
    expect(CheckoutEndpoints.preview(7), '/api/v1/checkout/vendor/7/preview');
    expect(CheckoutEndpoints.preview(null), '/api/v1/checkout/cart/preview');
  });

  test('the cart sends coupon_codes and the voucher', () {
    final Map<String, dynamic> body = CheckoutEndpoints.placeBody(
      addressId: 3,
      paymentMethod: 'wallet',
      driverTip: 5,
      discounts: discounts,
    );

    expect(body['coupon_codes'], <String, String>{'2': 'TWO', '9': 'NINE'});
    expect(body['voucher'], 'VCH-000001');
    expect(body['driver_tip'], 5);
    expect(body['address_id'], 3);
    expect(body.containsKey('coupons'), isFalse);
    expect(body.containsKey('coupon'), isFalse);
    expect(body.containsKey('payment_method_id'), isFalse);
  });

  test('a vendor sends its own coupon as `coupon`', () {
    final Map<String, dynamic> body = CheckoutEndpoints.placeBody(
      vendorId: 9,
      addressId: 3,
      paymentMethod: 'card',
      paymentMethodId: 11,
      discounts: discounts,
    );

    expect(body['coupon'], 'NINE');
    expect(body['voucher'], 'VCH-000001');
    expect(body['payment_method_id'], 11);
    expect(body.containsKey('coupon_codes'), isFalse);
  });

  test('no codes send nothing for them', () {
    final Map<String, dynamic> body = CheckoutEndpoints.pricingBody(
      vendorId: 1,
    );

    expect(body, isEmpty);
  });

  // The app adds the tip to the preview's total itself, so a preview priced
  // with one would count it twice — and a tip would cost a request again.
  test('only placing sends the tip, and a zero tip not even then', () {
    expect(
      CheckoutEndpoints.pricingBody(addressId: 3).containsKey('driver_tip'),
      isFalse,
    );
    expect(
      CheckoutEndpoints.placeBody(
        addressId: 3,
        paymentMethod: 'cod',
      ).containsKey('driver_tip'),
      isFalse,
    );
  });

  test('applying a coupon sends the delivery address when there is one', () {
    expect(
      CheckoutEndpoints.discountApplyBody(vendorId: 3, code: 'C', addressId: 7),
      <String, dynamic>{'vendor_id': 3, 'code': 'C', 'address_id': 7},
    );
    expect(
      CheckoutEndpoints.discountApplyBody(vendorId: 3, code: 'C'),
      <String, dynamic>{'vendor_id': 3, 'code': 'C'},
    );
  });
}
