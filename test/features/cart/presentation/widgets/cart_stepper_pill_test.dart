import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart_stepper_pill.dart';

import '../../../../helpers/categories_test_harness.dart';

// BUG-010/013/019: the card's +/- were 15 dp targets on low-contrast icons, and
// the "+" sat top-aligned. Each target is now a third of a ~40 dp tall box.
void main() {
  setUpAll(initCategoriesTestLocalization);

  Future<List<String>> tapEach(WidgetTester tester, int counter) async {
    final List<String> taps = <String>[];
    await pumpCategoriesWidget(
      tester,
      Align(
        alignment: AlignmentDirectional.bottomEnd,
        child: CartStepperPill(
          expanded: true,
          counter: counter,
          onInc: () => taps.add('inc'),
          onDec: () => taps.add('dec'),
          onDelete: () => taps.add('delete'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Rect box = tester.getRect(find.byType(CartStepperPill));
    // The harness is LTR: add sits at the start (left), remove at the end.
    for (final double x in <double>[1 / 6, 1 / 2, 5 / 6]) {
      await tester.tapAt(Offset(box.left + box.width * x, box.top + 4));
    }
    return taps;
  }

  testWidgets('one unit: add, nothing, delete', (WidgetTester tester) async {
    expect(await tapEach(tester, 1), <String>['inc', 'delete']);
  });

  testWidgets('two units: add, nothing, minus', (WidgetTester tester) async {
    expect(await tapEach(tester, 2), <String>['inc', 'dec']);
  });

  testWidgets('collapsed, the whole box opens it', (WidgetTester tester) async {
    int opens = 0;
    await pumpCategoriesWidget(
      tester,
      Center(
        child: CartStepperPill(
          expanded: false,
          counter: 0,
          onTap: () => opens++,
        ),
      ),
    );
    final Rect box = tester.getRect(find.byType(CartStepperPill));
    expect(box.size, const Size(40, 40));
    await tester.tapAt(box.topLeft + const Offset(2, 2));
    expect(opens, 1);
  });
}
