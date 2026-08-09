import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_sort_option.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourite_sort_sheet.dart';

import '../../../../helpers/favourites_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('renders the four sort options plus Apply and Reset',
      (WidgetTester tester) async {
    await pumpSheetViaRouter(
      tester,
      FavouriteSortSheet(
        initial: FavouriteSortOption.recent,
        onApply: (_) {},
      ),
    );

    // Labels fall back to their LangKeys keys under the empty test loader.
    expect(find.text('recent'), findsOneWidget);
    expect(find.text('oldest'), findsOneWidget);
    expect(find.text('priceLowestToHighest'), findsOneWidget);
    expect(find.text('priceHighestToLowest'), findsOneWidget);
    expect(find.byType(PrimaryAppButton), findsOneWidget);
    expect(find.byType(UnPrimaryAppButton), findsOneWidget);
  });

  testWidgets('Apply forwards the selected option', (WidgetTester tester) async {
    FavouriteSortOption? applied;
    await pumpSheetViaRouter(
      tester,
      FavouriteSortSheet(
        initial: FavouriteSortOption.recent,
        onApply: (FavouriteSortOption option) => applied = option,
      ),
    );

    await tester.tap(find.text('priceLowestToHighest'));
    await tester.pump();
    await tester.tap(find.byType(PrimaryAppButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(applied, FavouriteSortOption.priceLowestToHighest);
  });

  testWidgets('Reset returns the selection to the default (recent)',
      (WidgetTester tester) async {
    FavouriteSortOption? applied;
    await pumpSheetViaRouter(
      tester,
      FavouriteSortSheet(
        initial: FavouriteSortOption.priceHighestToLowest,
        onApply: (FavouriteSortOption option) => applied = option,
      ),
    );

    await tester.tap(find.byType(UnPrimaryAppButton)); // reset → recent
    await tester.pump();
    await tester.tap(find.byType(PrimaryAppButton)); // apply
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(applied, FavouriteSortOption.recent);
  });
}
