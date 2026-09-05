import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/vendor_discount_application_model.dart';
import 'package:nowdelivery_user_app/features/purchase_vouchers/data/models/purchase_voucher_model.dart';

// Guards the money/parse logic the two discount features depend on: decimal
// *string* money → double, applied:false-with-reason, and the voucher's typed
// fields + store translation map.
void main() {
  test('VendorDiscountApplicationModel parses string money and applied flag', () {
    final applied = VendorDiscountApplicationModel.fromJson(<String, dynamic>{
      'applied': true,
      'vendor_id': 12,
      'code': 'SAVE10',
      'currency': 'SAR',
      'subtotal': '100.00',
      'discount': '10.50',
      'subtotal_after_discount': '89.50',
      'reason': null,
    });

    expect(applied.applied, isTrue);
    expect(applied.vendorId, 12);
    expect(applied.discount, 10.50);
    expect(applied.subtotalAfterDiscount, 89.50);

    final rejected = VendorDiscountApplicationModel.fromJson(<String, dynamic>{
      'applied': false,
      'vendor_id': 12,
      'code': 'BAD',
      'discount': '0.00',
      'reason': 'Coupon not found.',
    });

    // A 200 with applied:false must parse cleanly and carry the reason.
    expect(rejected.applied, isFalse);
    expect(rejected.discount, 0.0);
    expect(rejected.reason, 'Coupon not found.');
  });

  test('PurchaseVoucherModel parses type, discount and store name map', () {
    final voucher = PurchaseVoucherModel.fromJson(<String, dynamic>{
      'id': 5,
      'code': 'VCH-000005',
      'name': 'Ramadan Deal',
      'type': 'store',
      'discount_type': 'percentage',
      'discount_value': 15.0,
      'starts_at': '2026-08-01T00:00:00.000000Z',
      'expires_at': '2026-09-30T23:59:59.000000Z',
      'stores': <dynamic>[
        <String, dynamic>{
          'id': 12,
          'name': <String, dynamic>{'en': 'Panda', 'ar': 'بندة'},
        },
      ],
    });

    expect(voucher.id, 5);
    expect(voucher.isPlatform, isFalse);
    expect(voucher.isPercentage, isTrue);
    expect(voucher.discountValue, 15.0);
    expect(voucher.stores.single.id, 12);
    expect(voucher.stores.single.name?['en'], 'Panda');
  });
}
