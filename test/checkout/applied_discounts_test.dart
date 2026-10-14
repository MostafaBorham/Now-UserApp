import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/applied_discounts_provider.dart';

// Coupon/voucher mutual exclusivity lives entirely in this notifier: applying
// either must cancel the other and report what it cancelled, so the screen can
// tell the user. A coupon only takes its own vendor's slot; a voucher clears
// every vendor's coupon.
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
  );
  const AppliedDiscountModel voucher = AppliedDiscountModel(
    vendorId: 1,
    code: 'VCHR',
    isVoucher: true,
  );

  test('a coupon cancels the same vendor\'s voucher and reports it', () {
    expect(notifier().add(voucher), isEmpty);

    final List<AppliedDiscountModel> displaced = notifier().add(coupon);

    expect(displaced.single.code, 'VCHR');
    expect(displaced.single.isVoucher, isTrue);
    expect(applied().single.code, 'SAVE10');
  });

  test('a voucher cancels the same vendor\'s coupon and reports it', () {
    expect(notifier().add(coupon), isEmpty);

    final List<AppliedDiscountModel> displaced = notifier().add(voucher);

    expect(displaced.single.code, 'SAVE10');
    expect(displaced.single.isVoucher, isFalse);
    expect(applied().single.code, 'VCHR');
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

  test('a coupon leaves another vendor\'s coupon alone', () {
    notifier().add(coupon);

    expect(
      notifier().add(const AppliedDiscountModel(vendorId: 2, code: 'OTHER')),
      isEmpty,
    );
    expect(applied().length, 2);
  });

  test('a voucher cancels every vendor\'s coupon, not just its own', () {
    notifier().add(coupon);
    notifier().add(
      const AppliedDiscountModel(vendorId: 2, code: 'OTHER'),
    );

    final List<AppliedDiscountModel> displaced = notifier().add(voucher);

    expect(
      displaced.map((AppliedDiscountModel d) => d.code),
      unorderedEquals(<String>['SAVE10', 'OTHER']),
    );
    expect(applied().single.code, 'VCHR');
  });
}
