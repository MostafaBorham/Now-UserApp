import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/home_view.dart';

/// The default 800×600 test view: the first section fills it, the second
/// starts just below it (built, inside the cache extent, but off screen).
///
/// Every feed section is kept alive and has its tickers muted while it is out
/// of the viewport — so an off-screen carousel or strip schedules no frames —
/// and rebuilds only when the data it is built from changes.
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

  group('content', () {
    // A favourite tap replaces the whole feed; only the sections holding that
    // product may rebuild.
    int builds = 0;
    setUp(() => builds = 0);

    Future<void> pumpSection(
      WidgetTester tester,
      Object? content, {
      Locale locale = const Locale('en', 'US'),
    }) => tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: const <Locale>[
          Locale('en', 'US'),
          Locale('en', 'GB'),
        ],
        home: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                HomeFeedSection(
                  content: content,
                  // A new instance every pump, as HomeView builds one.
                  child: _CountingChild(onBuild: () => builds++),
                ),
              ]),
            ),
          ],
        ),
      ),
    );

    testWidgets('unchanged content keeps the child it built', (
      WidgetTester tester,
    ) async {
      final Object section = Object();
      await pumpSection(tester, (section, true));
      await pumpSection(tester, (section, true));

      expect(builds, 1);
    });

    testWidgets('changed content rebuilds the child', (
      WidgetTester tester,
    ) async {
      final Object section = Object();
      await pumpSection(tester, (section, true));
      await pumpSection(tester, (section, false));
      await pumpSection(tester, (Object(), false));

      expect(builds, 3);
    });

    testWidgets('a language switch rebuilds it whatever the content', (
      WidgetTester tester,
    ) async {
      final Object section = Object();
      await pumpSection(tester, section);
      await pumpSection(tester, section, locale: const Locale('en', 'GB'));

      expect(builds, 2);
    });

    testWidgets('no content always rebuilds the child', (
      WidgetTester tester,
    ) async {
      await pumpSection(tester, null);
      await pumpSection(tester, null);

      expect(builds, 2);
    });
  });
}

class _CountingChild extends StatelessWidget {
  const _CountingChild({required this.onBuild});

  final VoidCallback onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild();
    return const SizedBox(height: 100);
  }
}
