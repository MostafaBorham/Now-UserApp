import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_bottom_sheet.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_products_filter_view.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_stores_filter_view.dart';

import '../../../../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  group('FilterBottomSheet (shared shell)', () {
    testWidgets('renders the supplied filters plus Apply and Reset',
        (WidgetTester tester) async {
      await pumpSheetViaRouter(
        tester,
        FilterBottomSheet(
          onApply: () {},
          onReset: () {},
          filters: const <Widget>[Text('__filter_slot__')],
        ),
      );

      expect(find.text('__filter_slot__'), findsOneWidget);
      expect(find.byType(PrimaryAppButton), findsOneWidget);
      expect(find.byType(UnPrimaryAppButton), findsOneWidget);
    });

    testWidgets('Apply invokes onApply and then pops the sheet',
        (WidgetTester tester) async {
      bool applied = false;
      await pumpSheetViaRouter(
        tester,
        FilterBottomSheet(
          onApply: () => applied = true,
          onReset: () {},
          filters: const <Widget>[Text('__filter_slot__')],
        ),
      );

      await tester.tap(find.byType(PrimaryAppButton));
      await tester.pump(); // start the pop
      await tester.pump(const Duration(milliseconds: 500)); // finish the route transition

      expect(applied, isTrue);
      // Popped back to the launcher route; the sheet's slot is gone.
      expect(find.text('__home__'), findsOneWidget);
      expect(find.text('__filter_slot__'), findsNothing);
    });

    testWidgets('Reset invokes onReset without popping',
        (WidgetTester tester) async {
      bool reset = false;
      await pumpSheetViaRouter(
        tester,
        FilterBottomSheet(
          onApply: () {},
          onReset: () => reset = true,
          filters: const <Widget>[Text('__filter_slot__')],
        ),
      );

      await tester.tap(find.byType(UnPrimaryAppButton));
      await tester.pump();

      expect(reset, isTrue);
      // Still on the sheet.
      expect(find.text('__filter_slot__'), findsOneWidget);
    });
  });

  group('CategoryProductsFilterView', () {
    testWidgets('forwards the selection through onApply on Apply',
        (WidgetTester tester) async {
      bool applied = false;
      await pumpSheetViaRouter(
        tester,
        CategoryProductsFilterView(
          onApply: (_, _, _, _) => applied = true,
        ),
      );

      expect(find.byType(PrimaryAppButton), findsOneWidget);
      await tester.tap(find.byType(PrimaryAppButton));
      await tester.pump();

      expect(applied, isTrue);
    });
  });

  group('CategoryStoresFilterView', () {
    testWidgets('forwards the selection through onApply on Apply',
        (WidgetTester tester) async {
      bool applied = false;
      await pumpSheetViaRouter(
        tester,
        CategoryStoresFilterView(onApply: (_, _) => applied = true),
      );

      expect(find.byType(PrimaryAppButton), findsOneWidget);
      await tester.tap(find.byType(PrimaryAppButton));
      await tester.pump();

      expect(applied, isTrue);
    });
  });
}
