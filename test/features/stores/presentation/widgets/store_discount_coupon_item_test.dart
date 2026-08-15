import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_discount_coupon_item.dart';

import '../../../../helpers/categories_test_harness.dart';

/// The ticket is a tight 121x158 box, so these tests double as an overflow
/// guard: any RenderFlex overflow inside it fails the pump.
void main() {
  setUpAll(initCategoriesTestLocalization);

  const CouponModel coupon = CouponModel(
    code: 'SAVE20',
    discountValue: 20,
    startsAt: '2026-01-10',
    expiresAt: '2026-01-31',
  );

  Future<void> pumpTicket(WidgetTester tester, {bool darkHead = false}) =>
      pumpCategoriesWidget(
        tester,
        Center(
          child: StoreDiscountCouponItem(
            coupon: coupon,
            storeName: 'Panda',
            darkHead: darkHead,
          ),
        ),
      );

  testWidgets('renders the discount, the store name and the validity', (
    WidgetTester tester,
  ) async {
    await pumpTicket(tester);

    expect(find.text('20%'), findsOneWidget);
    expect(find.textContaining('Panda'), findsOneWidget);
    expect(find.textContaining('January 10, 2026'), findsOneWidget);
    expect(
      tester.getSize(find.byType(StoreDiscountCouponItem)),
      const Size(121, 158),
    );
  });

  testWidgets('renders the dark head variant', (WidgetTester tester) async {
    await pumpTicket(tester, darkHead: true);

    expect(find.text('20%'), findsOneWidget);
  });

  testWidgets('drops the percent sign for a fixed-amount coupon', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      const Center(
        child: StoreDiscountCouponItem(
          coupon: CouponModel(
            code: 'FLAT15',
            isPercentage: false,
            discountValue: 15,
          ),
          storeName: 'Panda',
        ),
      ),
    );

    expect(find.text('15'), findsOneWidget);
    expect(find.text('15%'), findsNothing);
  });
}
