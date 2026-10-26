import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/top_wave_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/app_tab_bar.dart';

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

  group('flattenOnScroll', () {
    double flattening(WidgetTester tester) => tester
        .widgetList<ClipPath>(find.byType(ClipPath))
        .map((ClipPath clip) => clip.clipper)
        .whereType<TopWaveClipper>()
        .first
        .flattening!
        .value;

    Widget list() => ListView(
      children: [
        for (int i = 0; i < 40; i++) SizedBox(height: 80, child: Text('$i')),
      ],
    );

    // A tab bar body, as on category details: the lists sit a scrollable
    // deeper than the wave, inside the tabs' horizontal page view.
    Future<void> pumpTabs(WidgetTester tester, {required bool flatten}) =>
        pumpCategoriesWidget(
          tester,
          AppWavedView(
            appBarTitle: 'Title',
            canPop: false,
            flattenOnScroll: flatten,
            body: AppTabBar(
              tabs: const ['A', 'B'],
              views: [list(), list()],
              selectedTabColor: Colors.red,
            ),
          ),
        );

    Future<void> scroll(WidgetTester tester, double dy) async {
      await tester.drag(find.byType(ListView).first, Offset(0, dy));
      await tester.pumpAndSettle();
    }

    testWidgets('eases the wave flat off the top, and back at the top', (
      WidgetTester tester,
    ) async {
      await pumpTabs(tester, flatten: true);
      expect(flattening(tester), 0);

      await scroll(tester, -300);
      expect(flattening(tester), 1);

      await scroll(tester, 600);
      expect(flattening(tester), 0);
    });

    testWidgets('off by default: the wave stays put (BUG-009)', (
      WidgetTester tester,
    ) async {
      await pumpTabs(tester, flatten: false);

      await scroll(tester, -300);
      expect(flattening(tester), 0);
    });
  });
}
