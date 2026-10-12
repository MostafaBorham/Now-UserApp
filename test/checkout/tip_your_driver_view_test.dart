import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/tip_your_driver_view.dart';

import '../helpers/categories_test_harness.dart';

// The tip is charged, so it must start at nothing and be removable again —
// it used to preselect 2 SAR with no way back but fifteen taps on "Other".
void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('no tip until picked, and a second tap takes it back', (
    WidgetTester tester,
  ) async {
    final List<double> reported = <double>[];
    await pumpCategoriesWidget(
      tester,
      TipYourDriverView(onTipChanged: reported.add),
    );
    await tester.pump();

    expect(reported, isEmpty);

    await tester.tap(find.text('5'));
    await tester.tap(find.text('5'));

    expect(reported, <double>[5, 0]);
  });

  testWidgets('"Other" is a typed amount: digits only, 1000 at most', (
    WidgetTester tester,
  ) async {
    final List<double> reported = <double>[];
    await pumpCategoriesWidget(
      tester,
      TipYourDriverView(onTipChanged: reported.add),
    );
    await tester.pump();

    await tester.tap(find.text(LangKeys.otherKey.tr()));
    await tester.pump();
    expect(reported, <double>[0]);

    await tester.enterText(find.byType(TextField), '12a.3');
    expect(find.text('123'), findsOneWidget);
    expect(reported.last, 123);

    // The server refuses more than 1000, so a keystroke past it is ignored.
    await tester.enterText(find.byType(TextField), '1000');
    expect(reported.last, 1000);
    await tester.enterText(find.byType(TextField), '10000');
    expect(find.text('1000'), findsOneWidget);
    expect(reported.last, 1000);
  });
}
