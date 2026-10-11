import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';

import '../../../../helpers/categories_test_harness.dart';

// BUG-004: a store with no distance (no location to measure from) read "0 km".
void main() {
  setUpAll(initCategoriesTestLocalization);

  Finder km() => find.textContaining(LangKeys.kmKey);

  testWidgets('no distance, no distance shown', (WidgetTester tester) async {
    await pumpCategoriesWidget(
      tester,
      StoreCardView(store: const StoreModel(id: 1)),
    );
    expect(km(), findsNothing);
  });

  testWidgets('a known distance is shown', (WidgetTester tester) async {
    await pumpCategoriesWidget(
      tester,
      StoreCardView(store: const StoreModel(id: 1, distance: 2.5)),
    );
    expect(km(), findsOneWidget);
  });
}
