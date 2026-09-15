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






void main() {
  setUpAll(initCategoriesTestLocalization);



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

    expect(find.text('5 (2)'), findsOneWidget);

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

    expect(heart.favouriteType, FavouriteType.store);
    expect(heart.itemId, 3);


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

    expect(find.textContaining('minutes'), findsNothing);
    expect(find.textContaining('km'), findsNothing);
    expect(find.text('0'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('heads the section with the title the feed sent', (
    WidgetTester tester,
  ) async {



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
