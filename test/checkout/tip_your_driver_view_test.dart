import 'package:flutter_test/flutter_test.dart';
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
}
