import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/success_add_to_cart_view.dart';

/// The entrance is a 1.2s one-shot timeline: the product circle pops in first,
/// the check badge lands mid-way, and everything is at rest by the end. This
/// guards the ordering and — because the sheet is transient — that it stops.
void main() {
  Finder badgeOpacity() => find.descendant(
    of: find.byType(Positioned),
    matching: find.byType(Opacity),
  );

  double opacityOf(WidgetTester tester, Finder finder) =>
      tester.widget<Opacity>(finder).opacity;

  testWidgets('check badge lands after the product circle, then settles', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SuccessAddToCartView(
            productName: 'MacBook Air 3',
            // Empty URL short-circuits to a static placeholder: no network.
            productImageUrl: '',
          ),
        ),
      ),
    );

    // t = 0: nothing has arrived yet.
    expect(opacityOf(tester, badgeOpacity()), 0);

    // t = 300ms: the circle is in (its fade finishes at 150ms) but the badge
    // does not start until 350ms.
    await tester.pump(const Duration(milliseconds: 300));
    expect(opacityOf(tester, badgeOpacity()), 0);

    // t = 1200ms: the pass is over and everything is fully visible.
    await tester.pump(const Duration(milliseconds: 900));
    expect(opacityOf(tester, badgeOpacity()), 1);

    // It plays once and stays put: a looping entrance would wind the badge
    // back to invisible on its next pass.
    await tester.pump(const Duration(seconds: 4));
    expect(opacityOf(tester, badgeOpacity()), 1);
  });
}
