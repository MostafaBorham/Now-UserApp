import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/selected_store_coupons_provider.dart';
import 'package:nowdelivery_user_app/features/promotions/presentation/widgets/vouchers/voucher_ticket.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_discount_coupons_list.dart';

import '../../../../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  StoreModel storeWith(List<CouponModel> coupons) =>
      sampleStore().copyWith(coupons: coupons);

  /// A cart holding one line from store `1` — what makes the strip tappable.
  Override cartWithThisStore() => getCartProvider.overrideWith(
    (Ref ref) => GetCartViewModel(
      AsyncValue<CartModel>.data(
        CartModel(
          vendors: <CartVendorModel>[
            CartVendorModel(vendor: sampleStore()),
          ],
        ),
      ),
    ),
  );

  /// The picks the strip wrote, read straight off the scope it was pumped in.
  Map<int, String> picks(WidgetTester tester) => ProviderScope.containerOf(
    tester.element(find.byType(StoreDiscountCouponsList)),
  ).read(selectedStoreCouponsProvider);

  Future<void> pumpCoupons(
    WidgetTester tester,
    List<CouponModel> coupons, {
    List<Override> overrides = const <Override>[],
  }) => pumpCategoriesWidget(
    tester,
    const StoreDiscountCouponsList(),
    overrides: [
      storeProvider.overrideWithValue(storeWith(coupons)),
      ...overrides,
    ],
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

  testWidgets('a fixed-amount coupon reads as money, not a percentage', (
    WidgetTester tester,
  ) async {
    await pumpCoupons(tester, const [
      CouponModel(code: 'FLAT15', isPercentage: false, discountValue: 15),
    ]);

    // Two decimals, like every other amount the customer is charged: this used
    // to go through `toInt()`, so a 15.50 coupon advertised itself as 15.
    expect(find.text('15.00'), findsOneWidget);
    expect(find.text('15%'), findsNothing);
  });

  testWidgets('a coupon is display-only while the cart holds nothing from '
      'this store', (WidgetTester tester) async {
    await pumpCoupons(tester, const [coupon]);

    expect(
      tester.widget<VoucherTicket>(find.byType(VoucherTicket)).onTap,
      isNull,
    );

    await tester.tap(find.byType(VoucherTicket));
    await tester.pump();

    expect(picks(tester), isEmpty);
  });

  testWidgets('with the store in the cart, tapping picks the coupon and '
      'tapping again clears it', (WidgetTester tester) async {
    await pumpCoupons(
      tester,
      const [coupon],
      overrides: [cartWithThisStore()],
    );

    await tester.tap(find.byType(VoucherTicket));
    await tester.pump();

    expect(picks(tester), <int, String>{1: 'SAVE20'});
    expect(
      tester.widget<VoucherTicket>(find.byType(VoucherTicket)).isSelected,
      isTrue,
    );

    await tester.tap(find.byType(VoucherTicket));
    await tester.pump();

    expect(picks(tester), isEmpty);
  });

  testWidgets('a coupon with no code stays display-only even with a full '
      'cart', (WidgetTester tester) async {
    await pumpCoupons(
      tester,
      const [CouponModel(name: 'Panda', discountValue: 20)],
      overrides: [cartWithThisStore()],
    );

    expect(
      tester.widget<VoucherTicket>(find.byType(VoucherTicket)).onTap,
      isNull,
    );
  });
}
