import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/best_nearby_stores_list_item.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/best_nearby_stores_section.dart';

import '../helpers/categories_test_harness.dart';

/// Render checks for the `nearby_stores` section. Never `pumpAndSettle` these —
/// see the harness note (images and shimmers animate forever).
///
/// The harness loads no translations, so `.tr()` returns the key itself: the
/// unit suffixes below assert on `minutes` / `km` rather than real copy.
void main() {
  setUpAll(initCategoriesTestLocalization);

  /// A store shaped like the enriched feed vendor item — everything the card
  /// renders, and nothing the section doesn't use.
  StoreModel nearbyStore({
    int? id = 3,
    String name = 'Al-Nour Store',
    double? rating = 5.0,
    int? ratingCount = 2,
    double? deliveryFee = 12.0,
    String? deliveryTime = '15-25',
    double? distance = 0.6,
    bool? isFavorite = true,
  }) => StoreModel(
    id: id,
    name: <String, dynamic>{'en': name, 'ar': name},
    logoUrl: 'http://x/logo.png',
    coverUrl: 'http://x/cover.png',
    rating: rating,
    ratingCount: ratingCount,
    deliveryFee: deliveryFee,
    deliveryTime: deliveryTime,
    distance: distance,
    isFavorite: isFavorite,
  );

  /// The section needs a bounded height (its list sits in an `Expanded`), the
  /// same way `HomeView` wraps it in an `AspectRatio`.
  Future<void> pumpSection(
    WidgetTester tester,
    List<StoreModel> stores, {
    Map<String, dynamic>? title,
  }) => pumpCategoriesWidget(
    tester,
    AspectRatio(
      aspectRatio: 1.47,
      child: BestNearbyStoresSection(title: title, stores: stores),
    ),
  );

  testWidgets('renders the store name and every detail the feed sent', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester, <StoreModel>[nearbyStore()]);

    expect(find.text('Al-Nour Store'), findsOneWidget);
    // Rating and its count share one pill: "5 (2)".
    expect(find.text('5 (2)'), findsOneWidget);
    // Delivery fee, beside the riyal glyph.
    expect(find.text('12'), findsOneWidget);
    expect(find.text('15-25 minutes'), findsOneWidget);
    expect(find.text('0.6 km'), findsOneWidget);
  });

  testWidgets('wires the favourite heart to this store', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester, <StoreModel>[nearbyStore()]);

    final CircularAppFavouriteIcon heart = tester.widget(
      find.byType(CircularAppFavouriteIcon),
    );
    // Integrated, not the local-flip fallback: a tap hits the favourites API.
    expect(heart.favouriteType, FavouriteType.store);
    expect(heart.itemId, 3);
    // Seeded from the feed, so an already-favourited store opens filled and
    // its first tap removes rather than re-adds.
    expect(heart.isFavourite, isTrue);
  });

  testWidgets('starts the heart empty when the feed omits is_favorite', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester, <StoreModel>[nearbyStore(isFavorite: null)]);

    final CircularAppFavouriteIcon heart = tester.widget(
      find.byType(CircularAppFavouriteIcon),
    );
    expect(heart.isFavourite, isFalse);
    expect(heart.favouriteType, FavouriteType.store);
  });

  testWidgets('leaves the heart un-integrated for a store with no id', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester, <StoreModel>[nearbyStore(id: null)]);

    final CircularAppFavouriteIcon heart = tester.widget(
      find.byType(CircularAppFavouriteIcon),
    );
    // No id to favourite by, so the icon falls back to flipping locally
    // instead of firing a request that could not name a store.
    expect(heart.itemId, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('omits the rows a thin vendor item has no data for', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester, <StoreModel>[
      nearbyStore(
        rating: null,
        ratingCount: null,
        deliveryFee: null,
        deliveryTime: null,
        distance: null,
      ),
    ]);

    expect(find.text('Al-Nour Store'), findsOneWidget);
    // Nothing rendered as a zero in place of the missing details.
    expect(find.textContaining('minutes'), findsNothing);
    expect(find.textContaining('km'), findsNothing);
    expect(find.text('0'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('heads the section with the title the feed sent', (
    WidgetTester tester,
  ) async {
    // The backend owns section headings — it sends both locales and the app
    // picks the current one, displaying it verbatim rather than second-guessing
    // it with its own label. The harness runs in English.
    await pumpSection(
      tester,
      <StoreModel>[nearbyStore()],
      title: <String, dynamic>{'en': 'Closest to you', 'ar': 'الأقرب إليك'},
    );

    expect(find.text('Closest to you'), findsOneWidget);
    expect(find.text(LangKeys.bestNearbyStoresKey), findsNothing);
  });

  testWidgets('uses the other locale when the feed titled only one', (
    WidgetTester tester,
  ) async {
    // Several sections come back with `ar` alone; showing that beats falling
    // back to the app's own label, which would ignore the admin's heading.
    await pumpSection(
      tester,
      <StoreModel>[nearbyStore()],
      title: <String, dynamic>{'ar': 'الأقرب إليك'},
    );

    expect(find.text('الأقرب إليك'), findsOneWidget);
    expect(find.text(LangKeys.bestNearbyStoresKey), findsNothing);
  });

  testWidgets('falls back to the app label when the feed sent no title', (
    WidgetTester tester,
  ) async {
    // Only an empty/absent title hands over to the app's own label, which the
    // harness renders as the bare key (it loads no translations).
    for (final Map<String, dynamic>? empty in <Map<String, dynamic>?>[
      null,
      <String, dynamic>{},
      <String, dynamic>{'en': '', 'ar': ''},
    ]) {
      await pumpSection(tester, <StoreModel>[nearbyStore()], title: empty);
      expect(find.text(LangKeys.bestNearbyStoresKey), findsOneWidget);
    }
  });

  test('the fallback label is translated in both shipped locales', () {
    // Guards the fallback path above: a key missing from either bundle would
    // put the bare `bestNearbyStores` on screen, and an identical pair would
    // reintroduce the bug this section already hit once — one language reading
    // the other's heading.
    Map<String, dynamic> bundle(String locale) =>
        jsonDecode(File('assets/json/lang/$locale.json').readAsStringSync())
            as Map<String, dynamic>;

    final String en = bundle('en-US')[LangKeys.bestNearbyStoresKey] as String;
    final String ar = bundle('ar-EG')[LangKeys.bestNearbyStoresKey] as String;

    expect(en, isNotEmpty);
    expect(ar, isNotEmpty);
    expect(en, isNot(ar));
  });

  testWidgets('renders one card per store', (WidgetTester tester) async {
    await pumpSection(tester, <StoreModel>[
      nearbyStore(id: 1, name: 'First'),
      nearbyStore(id: 2, name: 'Second'),
    ]);

    expect(find.byType(BestNearbyStoresListItem), findsNWidgets(2));
  });
}
