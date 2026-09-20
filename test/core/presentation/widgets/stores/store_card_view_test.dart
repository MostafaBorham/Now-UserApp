import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';

import '../../../../helpers/categories_test_harness.dart';

/// The card's default tap opens store details by id. A store that arrived
/// without an id has nothing to open, and the card must stay inert: the router
/// used to turn the missing id into `0` and the details screen then requested
/// `/api/v1/stores/0`, which the API answers with a 404.
///
/// Never `pumpAndSettle` these — see the harness note (images animate forever).
void main() {
  setUpAll(initCategoriesTestLocalization);

  StoreModel cardStore({required int? id}) => StoreModel(
    id: id,
    name: <String, dynamic>{'en': 'Al-Nour Store', 'ar': 'متجر النور'},
    logoUrl: 'http://x/logo.png',
    coverUrl: 'http://x/cover.png',
    rating: 5.0,
    ratingCount: 2,
    deliveryFee: 12.0,
    deliveryTime: '15-25',
    distance: 2.5,
    isFavorite: false,
  );

  /// The card's own tap target — the outermost [InkWell] in its subtree.
  InkWell cardInkWell(WidgetTester tester) => tester.widget<InkWell>(
    find
        .descendant(
          of: find.byType(StoreCardView),
          matching: find.byType(InkWell),
        )
        .first,
  );

  Future<void> pumpCard(WidgetTester tester, StoreModel store) =>
      pumpCategoriesWidget(
        tester,
        Center(
          child: SizedBox(
            width: 340,
            height: 220,
            child: StoreCardView(store: store),
          ),
        ),
      );

  testWidgets('a store with an id is tappable', (WidgetTester tester) async {
    await pumpCard(tester, cardStore(id: 7));

    // Card is mounted (guards against a false pass on an empty tree)...
    expect(find.byType(StoreCardView), findsOneWidget);
    // ...and its default tap is wired.
    expect(cardInkWell(tester).onTap, isNotNull);
  });

  testWidgets('a store without an id does not navigate', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester, cardStore(id: null));

    expect(find.byType(StoreCardView), findsOneWidget);
    expect(cardInkWell(tester).onTap, isNull);
  });

  testWidgets('an explicit onTap still wins over the id guard', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      Center(
        child: SizedBox(
          width: 340,
          height: 220,
          child: StoreCardView(store: cardStore(id: null), onTap: () {}),
        ),
      ),
    );

    expect(cardInkWell(tester).onTap, isNotNull);
  });
}
