import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_page_transitions.dart';

/// Screen changes slide in from the reading edge, over a set duration, and
/// settle exactly in place.
void main() {
  Future<NavigatorState> pumpApp(
    WidgetTester tester, {
    TextDirection direction = TextDirection.ltr,
  }) async {
    final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        theme: ThemeData(
          platform: TargetPlatform.android,
          pageTransitionsTheme: appPageTransitionsTheme,
        ),
        builder: (BuildContext context, Widget? child) =>
            Directionality(textDirection: direction, child: child!),
        home: const Scaffold(body: Text('first')),
      ),
    );
    return navigator.currentState!;
  }

  void push(NavigatorState navigator) => navigator.push(
    MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: Text('second')),
    ),
  );

  double leftOf(WidgetTester tester, String text) =>
      tester.getTopLeft(find.text(text)).dx;

  testWidgets('Android uses the slide and its duration', (
    WidgetTester tester,
  ) async {
    final NavigatorState navigator = await pumpApp(tester);
    push(navigator);
    await tester.pump();

    final Route<dynamic> route = ModalRoute.of(
      tester.element(find.text('second', skipOffstage: false)),
    )!;
    expect(
      (route as PageRoute<dynamic>).transitionDuration,
      AppSlidePageTransitionsBuilder.duration,
    );
  });

  testWidgets('in English the new screen comes in from the right', (
    WidgetTester tester,
  ) async {
    final NavigatorState navigator = await pumpApp(tester);
    final double width =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;

    push(navigator);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final double midway = leftOf(tester, 'second');
    expect(midway, greaterThan(0));
    expect(midway, lessThan(width));
    // The screen beneath drifts the other way.
    expect(leftOf(tester, 'first'), lessThan(0));

    await tester.pumpAndSettle();
    expect(leftOf(tester, 'second'), 0);
  });

  testWidgets('in Arabic the new screen comes in from the left', (
    WidgetTester tester,
  ) async {
    final NavigatorState navigator = await pumpApp(
      tester,
      direction: TextDirection.rtl,
    );

    push(navigator);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final Rect midway = tester.getRect(find.byType(Scaffold).last);
    expect(midway.left, lessThan(0));

    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(Scaffold).last).left, 0);
  });

  testWidgets('popping slides the screen back out and reveals the first', (
    WidgetTester tester,
  ) async {
    final NavigatorState navigator = await pumpApp(tester);
    push(navigator);
    await tester.pumpAndSettle();

    navigator.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(leftOf(tester, 'second'), greaterThan(0));

    await tester.pumpAndSettle();
    expect(find.text('second'), findsNothing);
    expect(leftOf(tester, 'first'), 0);
  });
}
