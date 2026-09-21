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

  testWidgets('no discount badge is claimed on the card', (
    WidgetTester tester,
  ) async {
    // The card used to paint a hardcoded "25%" flash over every store's cover,
    // on the All Stores screen, the home feed, favourites and category stores
    // alike. Nothing in the store payload backs a discount, so there is no
    // badge until a real field exists.
    await pumpCard(tester, cardStore(id: 7));

    expect(find.text('25%'), findsNothing);
    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('the delivery fee is shown to two decimals', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester, cardStore(id: 7));

    expect(find.text('12.00'), findsOneWidget);
  });

  testWidgets('a placeholder card fetches no images', (
    WidgetTester tester,
  ) async {
    // With no store this is a shimmer skeleton. It used to fall back to two
    // hardcoded third-party demo URLs, so every list's loading state fired real
    // requests at hosts the app has no relationship with.
    await pumpCategoriesWidget(
      tester,
      const Center(
        child: SizedBox(width: 340, height: 220, child: StoreCardView()),
      ),
    );

    for (final Image image in tester.widgetList<Image>(find.byType(Image))) {
      expect(image.image, isNot(isA<NetworkImage>()));
    }
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
