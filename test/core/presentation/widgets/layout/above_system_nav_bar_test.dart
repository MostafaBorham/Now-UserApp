import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/layout/above_system_nav_bar.dart';

/// BUG-001 (QA V2): with Android drawing the app under a 48dp 3-button
/// navigation bar, a bottom sheet's last button sat under the bar.
void main() {
  testWidgets('a bottom sheet\'s button stays above the navigation bar', (
    WidgetTester tester,
  ) async {
    const double navBar = 48;
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.viewPadding = const FakeViewPadding(bottom: navBar);
    tester.view.padding = const FakeViewPadding(bottom: navBar);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        builder: (BuildContext context, Widget? child) =>
            AboveSystemNavBar(child: child!),
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(height: 200),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Add New Card'),
                        ),
                      ],
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final double buttonBottom = tester
        .getRect(find.widgetWithText(ElevatedButton, 'Add New Card'))
        .bottom;
    expect(buttonBottom, lessThanOrEqualTo(800 - navBar));
  });
}
