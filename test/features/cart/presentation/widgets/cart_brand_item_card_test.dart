import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_item_card/cart_brand_item_card.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_item_details_view.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_brand_item_card/widgets/cart_item_checkout_view.dart';

import '../../../../helpers/categories_test_harness.dart';

/// The store card owns its expanded/collapsed state, and the cart renders a
/// list of them. Without a per-store key Flutter recycles the elements by
/// index, so removing a store hands its neighbour's expansion to whoever slides
/// up into the freed slot.
void main() {
  setUpAll(initCategoriesTestLocalization);

  CartVendorModel vendorOf(int id, String name, {bool checkoutable = true}) {
    return CartVendorModel(
      vendor: StoreModel(id: id, name: <String, dynamic>{'en': name}),
      products: <ProductModel>[
        ProductModel(productId: id * 10, quantity: 1, images: const <String>[]),
      ],
      pricing: CartVendorPricingModel(
        available: checkoutable,
        minOrderMet: checkoutable,
        minOrderValue: checkoutable ? 0 : 50,
        subtotal: checkoutable ? 80 : 20,
        total: checkoutable ? 80 : 20,
      ),
    );
  }

  /// The list as the cart screen builds it — keyed by store.
  Widget listOf(List<CartVendorModel> vendors) {
    return ListView(
      children: <Widget>[
        for (final CartVendorModel v in vendors)
          CartBrandItemCard(key: ValueKey<int>(v.vendor.id!), cartVendor: v),
      ],
    );
  }

  /// Expanded renders [CartBrandItemDetailsView]; collapsed renders the
  /// thumbnail strip instead. Both contain InkWells, so the body type is what
  /// tells the two states apart.
  bool isExpanded(WidgetTester tester, String storeName) {
    final Finder card = find.ancestor(
      of: find.text(storeName),
      matching: find.byType(CartBrandItemCard),
    );
    return find
        .descendant(of: card, matching: find.byType(CartBrandItemDetailsView))
        .evaluate()
        .isNotEmpty;
  }

  testWidgets('expansion stays with its own store when another is removed', (
    WidgetTester tester,
  ) async {
    final CartVendorModel panda = vendorOf(1, 'Panda');
    final CartVendorModel othaim = vendorOf(2, 'Othaim');

    await pumpCategoriesWidget(
      tester,
      listOf(<CartVendorModel>[panda, othaim]),
    );
    await tester.pumpAndSettle();

    // Expand the *second* store. By its arrow: the name opens the store.
    await tester.tap(
      find.descendant(
        of: find.ancestor(
          of: find.text('Othaim'),
          matching: find.byType(CartBrandItemCard),
        ),
        matching: find.byIcon(Icons.keyboard_arrow_down_rounded),
      ),
    );
    await tester.pumpAndSettle();

    expect(isExpanded(tester, 'Othaim'), isTrue);
    expect(isExpanded(tester, 'Panda'), isFalse);

    // Now the first store is removed, exactly as a "delete all" does.
    await pumpCategoriesWidget(tester, listOf(<CartVendorModel>[othaim]));
    await tester.pumpAndSettle();

    // Othaim is now at index 0, where Panda's collapsed state used to live.
    // With a key it keeps its own expansion; without one it would inherit.
    expect(find.text('Panda'), findsNothing);
    expect(isExpanded(tester, 'Othaim'), isTrue);
  });

  testWidgets('tapping the store name opens the store, not the card', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesScreen(
      tester,
      Scaffold(body: CartBrandItemCard(cartVendor: vendorOf(7, 'Panda'))),
      destinationRoutes: <RouteBase>[
        GoRoute(
          name: AppRoutes.storeDetailsScreen,
          path: '/${AppRoutes.storeDetailsScreen}/:id',
          builder: (BuildContext context, GoRouterState state) => Scaffold(
            body: Text('__store ${state.pathParameters['id']}__'),
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Panda'));
    await tester.pumpAndSettle();

    expect(find.text('__store 7__'), findsOneWidget);
  });

  testWidgets('a store under its minimum cannot be checked out', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await pumpCategoriesWidget(
      tester,
      CartBrandItemCard(
        cartVendor: vendorOf(1, 'Panda', checkoutable: false),
        onCheckout: () => tapped = true,
      ),
    );
    await tester.pumpAndSettle();

    final CartItemCheckoutView pill = tester.widget<CartItemCheckoutView>(
      find.byType(CartItemCheckoutView),
    );
    expect(pill.blockedReason, isNotNull);

    // The reason is shown rather than left to a failed request. (The test
    // harness loads no translations, so assert on the row, not its wording.)
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);

    // Tap by widget, not by label: the label is localized.
    final PrimaryAppButton button = tester.widget<PrimaryAppButton>(
      find.byType(PrimaryAppButton),
    );
    expect(button.onTap, isNull);

    await tester.tap(find.byType(PrimaryAppButton));
    await tester.pumpAndSettle();
    expect(tapped, isFalse);
  });

  testWidgets('a checkoutable store reports no reason and fires onCheckout', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await pumpCategoriesWidget(
      tester,
      CartBrandItemCard(
        cartVendor: vendorOf(1, 'Panda'),
        onCheckout: () => tapped = true,
      ),
    );
    await tester.pumpAndSettle();

    final CartItemCheckoutView pill = tester.widget<CartItemCheckoutView>(
      find.byType(CartItemCheckoutView),
    );
    expect(pill.blockedReason, isNull);
    expect(find.byIcon(Icons.info_outline_rounded), findsNothing);

    await tester.tap(find.byType(PrimaryAppButton));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  // BUG-033: a single-store cart had this pill and the footer button doing the
  // same thing. With no onCheckout the pill goes, but the reason stays.
  testWidgets('no onCheckout: no pill, the blocked reason still shows', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      CartBrandItemCard(cartVendor: vendorOf(1, 'Panda', checkoutable: false)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PrimaryAppButton), findsNothing);
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
  });
}
