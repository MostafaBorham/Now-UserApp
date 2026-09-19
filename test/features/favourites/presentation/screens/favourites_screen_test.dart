import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/screens/favourites_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

import '../../../../helpers/favourites_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  List<Override> screenOverrides() => <Override>[
        overrideFavouriteProducts(
          AsyncValue<PaginationModel<ProductModel>>.data(
            pageOf<ProductModel>(<ProductModel>[sampleProduct(en: 'Pizza')]),
          ),
        ),
        overrideFavouriteStores(
          AsyncValue<PaginationModel<StoreModel>>.data(
            pageOf<StoreModel>(<StoreModel>[sampleStore(en: 'Corner Shop')]),
          ),
        ),

        overrideFavouriteCategories(const []),
      ];

  testWidgets('renders both tabs inside a Scaffold and shows product cards',
      (WidgetTester tester) async {
    await pumpCategoriesScreen(
      tester,
      const FavouritesScreen(),
      overrides: screenOverrides(),
    );

    expect(find.text('products'), findsOneWidget);
    expect(find.text('stores'), findsOneWidget);



    expect(find.byType(Scaffold), findsWidgets);
    expect(find.byType(ProductItem3View), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching to the Stores tab shows store cards',
      (WidgetTester tester) async {
    await pumpCategoriesScreen(
      tester,
      const FavouritesScreen(),
      overrides: screenOverrides(),
    );

    await tester.tap(find.text('stores'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));




    for (dynamic ex = tester.takeException();
        ex != null;
        ex = tester.takeException()) {
      expect(ex.toString(), contains('overflow'));
    }

    expect(find.byType(StoreCardView), findsWidgets);
  });
}
