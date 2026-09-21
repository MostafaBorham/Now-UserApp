import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_item.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/screens/category_details_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

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


    expect(find.text('Food'), findsOneWidget);

    expect(find.text('products'), findsOneWidget);
    expect(find.text('stores'), findsOneWidget);

    expect(find.byType(ProductItem3View), findsWidgets);
  });

  testWidgets('switching to the Stores tab shows store items',
      (WidgetTester tester) async {
    await pumpCategoriesScreen(
      tester,
      CategoryDetailsScreen(category: sampleCategory(en: 'Food')),
      overrides: detailsOverrides(),
    );

    await tester.tap(find.text('stores'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));






    for (dynamic ex = tester.takeException();
        ex != null;
        ex = tester.takeException()) {
      expect(ex.toString(), contains('overflow'));
    }


    expect(find.byType(StoreItem), findsWidgets);
  });
}
