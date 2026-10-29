import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_status_badge.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_item_card/widgets/cart_item_checkout_view.dart';

import '../../../../helpers/categories_test_harness.dart';

/// The backend sends a store's state as two flags: closed is `is_open: false`,
/// busy is `is_open: true, accepting_orders: false`. A payload without them
/// (the cart and checkout, until the backend adds them) shows no pill.
void main() {
  setUpAll(initCategoriesTestLocalization);

  Future<void> pumpBadge(WidgetTester tester, StoreModel store) =>
      pumpCategoriesWidget(
        tester,
        Center(child: StoreStatusBadge(store: store)),
      );

  testWidgets('closed and busy get a pill, open and flagless get none', (
    WidgetTester tester,
  ) async {
    await pumpBadge(
      tester,
      const StoreModel(isOpen: false, acceptingOrders: false),
    );
    expect(find.text(LangKeys.storeClosedKey), findsOneWidget);

    await pumpBadge(
      tester,
      const StoreModel(isOpen: true, acceptingOrders: false),
    );
    expect(find.text(LangKeys.storeBusyKey), findsOneWidget);

    for (final StoreModel store in const <StoreModel>[
      StoreModel(isOpen: true, acceptingOrders: true),
      StoreModel(),
    ]) {
      await pumpBadge(tester, store);
      expect(find.byType(Text), findsNothing);
    }
  });

  test('the cart keeps the vendor flags', () {
    final CartVendorModel vendor = CartVendorModel.fromJson(<String, dynamic>{
      'vendor': <String, dynamic>{
        'id': 1,
        'is_open': true,
        'accepting_orders': false,
      },
    });
    expect(vendor.vendor.isBusy, isTrue);
  });

  testWidgets('a closed store says so instead of the generic line', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      const CartItemCheckoutView(
        pricing: CartVendorPricingModel(),
        storeClosed: true,
      ),
    );
    expect(find.text(LangKeys.cartStoreClosedKey), findsOneWidget);
    expect(find.text(LangKeys.cartStoreUnavailableKey), findsNothing);
  });
}
