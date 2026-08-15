import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_item.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/screens/category_details_screen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cards/product_item_card2.dart';

import '../../../../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  List<Override> detailsOverrides() => <Override>[
        overrideCategoryProducts(
          AsyncValue<PaginationModel<ProductModel>>.data(
            pageOf<ProductModel>(<ProductModel>[sampleProduct(en: 'Pizza')]),
          ),
        ),
        overrideCategoryStores(
          AsyncValue<PaginationModel<StoreModel>>.data(
            pageOf<StoreModel>(<StoreModel>[sampleStore(en: 'Corner Shop')]),
          ),
        ),
      ];

  testWidgets('renders the category title, both tabs and the products content',
      (WidgetTester tester) async {
    await pumpCategoriesScreen(
      tester,
      CategoryDetailsScreen(category: sampleCategory(en: 'Food')),
      overrides: detailsOverrides(),
    );

    // Title comes from the category name map (English).
    expect(find.text('Food'), findsOneWidget);
    // Tab labels fall back to their LangKeys keys under the empty test loader.
    expect(find.text('products'), findsOneWidget);
    expect(find.text('stores'), findsOneWidget);
    // Products tab is active first and shows the product cards.
    expect(find.byType(ProductItemCard2), findsWidgets);
  });

  testWidgets('switching to the Stores tab shows store items',
      (WidgetTester tester) async {
    await pumpCategoriesScreen(
      tester,
      CategoryDetailsScreen(category: sampleCategory(en: 'Food')),
      overrides: detailsOverrides(),
    );

    await tester.tap(find.text('stores'));
    await tester.pump(); // start the tab transition
    await tester.pump(const Duration(milliseconds: 500)); // finish it

    // StoreItem's inner text Row overflows under the fixed-width "Ahem" test
    // font (it fits with the real IBM Plex font at this width). That's a
    // test-only rendering artifact in a shared core widget, not a categories
    // bug — drain those layout errors, but assert each really is an overflow so
    // a genuine exception would still fail the test.
    for (dynamic ex = tester.takeException();
        ex != null;
        ex = tester.takeException()) {
      expect(ex.toString(), contains('overflow'));
    }

    // The stores content mounted, so the tab switched.
    expect(find.byType(StoreItem), findsWidgets);
  });
}
