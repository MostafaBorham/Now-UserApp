import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/applied_discounts_provider.dart';

// Coupon/voucher mutual exclusivity lives entirely in the vendor's single slot:
// applying either must cancel the other and report what it cancelled, so the
// screen can tell the user. Per-vendor, not global — a second store keeps its
// own discount.
void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  AppliedDiscountsNotifier notifier() =>
      container.read(appliedDiscountsProvider.notifier);

  List<AppliedDiscountModel> applied() =>
      container.read(appliedDiscountsProvider);

  const AppliedDiscountModel coupon = AppliedDiscountModel(
    vendorId: 1,
    code: 'SAVE10',
    discount: 10,
  );
  const AppliedDiscountModel voucher = AppliedDiscountModel(
    vendorId: 1,
    code: 'VCHR',
    discount: 25,
    isVoucher: true,
  );

  test('a coupon cancels the same vendor\'s voucher and reports it', () {
    expect(notifier().add(voucher), isNull);

    final AppliedDiscountModel? replaced = notifier().add(coupon);

    expect(replaced?.code, 'VCHR');
    expect(replaced?.isVoucher, isTrue);
    expect(applied().single.code, 'SAVE10');
    expect(applied().single.discount, 10);
  });

  test('a voucher cancels the same vendor\'s coupon and reports it', () {
    expect(notifier().add(coupon), isNull);

    final AppliedDiscountModel? replaced = notifier().add(voucher);

    expect(replaced?.code, 'SAVE10');
    expect(replaced?.isVoucher, isFalse);
    expect(applied().single.code, 'VCHR');
    expect(applied().single.discount, 25);
  });

  test('a second voucher displaces the first, whichever vendor holds it', () {
    notifier().add(voucher);
    notifier().add(
      const AppliedDiscountModel(vendorId: 2, code: 'SAVE5'),
    );

    notifier().add(
      const AppliedDiscountModel(vendorId: 2, code: 'V2', isVoucher: true),
    );

    // The place request takes one `voucher`, so vendor 1's is gone — and the
    // new one took vendor 2's slot from its coupon.
    expect(applied().single.code, 'V2');
  });

  test('another vendor keeps its own discount', () {
    notifier().add(coupon);
    notifier().add(
      const AppliedDiscountModel(vendorId: 2, code: 'OTHER', discount: 5),
    );

    expect(notifier().add(voucher), isNotNull);
    expect(applied().length, 2);
    expect(
      applied().map((AppliedDiscountModel d) => d.code),
      containsAll(<String>['OTHER', 'VCHR']),
    );
  });
}
