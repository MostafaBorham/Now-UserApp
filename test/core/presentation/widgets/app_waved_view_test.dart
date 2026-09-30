import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';

import '../../../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('the title is centred even with only a back button', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      const AppWavedView(appBarTitle: 'Title', canPop: true, body: SizedBox()),
    );

    expect(
      tester.getCenter(find.text('Title')).dx,
      moreOrLessEquals(
        tester.getCenter(find.byType(AppWavedView)).dx,
        epsilon: 0.5,
      ),
    );
  });
}
