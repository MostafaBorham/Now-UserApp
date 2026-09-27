import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/home_view.dart';

/// The default 800×600 test view: the first section fills it, the second
/// starts just below it (built, inside the cache extent, but off screen).
///
/// Every feed section is kept alive and has its tickers muted while it is out
/// of the viewport — so an off-screen carousel or strip schedules no frames.
void main() {
  const Key first = Key('first');
  const Key second = Key('second');

  Future<ScrollController> pumpFeed(WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: CustomScrollView(
          controller: controller,
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                const HomeFeedSection(child: SizedBox(key: first, height: 700)),
                const HomeFeedSection(
                  child: SizedBox(key: second, height: 1000),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    return controller;
  }

  bool tickersOn(WidgetTester tester, Key key) => TickerMode.valuesOf(
    tester.element(find.byKey(key, skipOffstage: false)),
  ).enabled;

  testWidgets('a section below the viewport has its tickers muted', (
    WidgetTester tester,
  ) async {
    await pumpFeed(tester);

    expect(tickersOn(tester, first), isTrue);
    expect(tickersOn(tester, second), isFalse);
  });

  testWidgets('scrolled away it stays alive, muted, and resumes on return', (
    WidgetTester tester,
  ) async {
    final ScrollController controller = await pumpFeed(tester);

    // Far enough that the first section leaves the cache extent too and lives
    // on only because it is kept alive.
    controller.jumpTo(1100);
    await tester.pump();
    await tester.pump();
    expect(tickersOn(tester, first), isFalse);
    expect(tickersOn(tester, second), isTrue);

    controller.jumpTo(0);
    await tester.pump();
    await tester.pump();
    expect(tickersOn(tester, first), isTrue);
    expect(tickersOn(tester, second), isFalse);
  });
}
