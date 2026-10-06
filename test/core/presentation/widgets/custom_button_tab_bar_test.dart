import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';

import '../../../helpers/categories_test_harness.dart';

/// BUG-010 (QA V2): a bar rebuilt with a new key (favourites keys it on the tab
/// count) opened on tab 0 while the caller had another tab selected, leaving
/// that tab's list on its shimmer.
void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('opens on the selected tab', (WidgetTester tester) async {
    await pumpCategoriesWidget(
      tester,
      const CustomButtonTabBar(
        tabs: <String>['All', 'Food', 'Toys'],
        views: <Widget>[Text('all view'), Text('food view'), Text('toys view')],
        selectedIndex: 2,
        unSelectedTabColor: Colors.grey,
      ),
    );

    expect(find.text('toys view'), findsOneWidget);
    expect(find.text('all view'), findsNothing);
  });

  testWidgets('an out-of-range selection falls back to the first tab', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      const CustomButtonTabBar(
        tabs: <String>['All', 'Food'],
        views: <Widget>[Text('all view'), Text('food view')],
        selectedIndex: 5,
        unSelectedTabColor: Colors.grey,
      ),
    );

    expect(find.text('all view'), findsOneWidget);
  });
}
