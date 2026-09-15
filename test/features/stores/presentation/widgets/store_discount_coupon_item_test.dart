import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/promotions/presentation/widgets/vouchers/voucher_ticket.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_discount_coupons_list.dart';

import '../../../../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  StoreModel storeWith(List<CouponModel> coupons) =>
      sampleStore().copyWith(coupons: coupons);

  Future<void> pumpCoupons(WidgetTester tester, List<CouponModel> coupons) =>
      pumpCategoriesWidget(
        tester,
        const StoreDiscountCouponsList(),
        overrides: [storeProvider.overrideWithValue(storeWith(coupons))],
      );

  const CouponModel coupon = CouponModel(
    code: 'SAVE20',
    name: 'Panda',
    discountValue: 20,
    startsAt: '2026-01-10',
    expiresAt: '2026-01-31',
  );

  testWidgets('renders the discount, the coupon name and the validity', (
    WidgetTester tester,
  ) async {
    await pumpCoupons(tester, const [coupon]);

    expect(find.text('20%'), findsOneWidget);
    expect(find.textContaining('Panda'), findsOneWidget);
    expect(find.textContaining('January 10, 2026'), findsOneWidget);

    final Size size = tester.getSize(find.byType(VoucherTicket));
    expect(size.width, 121);
    expect(size.height, greaterThanOrEqualTo(158));
  });

  testWidgets('renders the dark-head variant without overflow', (
    WidgetTester tester,
  ) async {
    await pumpCoupons(tester, const [coupon, coupon]);

    expect(find.byType(VoucherTicket), findsNWidgets(2));
  });

  testWidgets('drops the percent sign for a fixed-amount coupon', (
    WidgetTester tester,
  ) async {
    await pumpCoupons(tester, const [
      CouponModel(code: 'FLAT15', isPercentage: false, discountValue: 15),
    ]);

    expect(find.text('15'), findsOneWidget);
    expect(find.text('15%'), findsNothing);
  });
}
