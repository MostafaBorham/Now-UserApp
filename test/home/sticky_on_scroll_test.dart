import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/sticky_on_scroll.dart';

// BUG-008: the pin point was measured once, so content above that changed
// height later (live orders, special offers) parked the bar in the wrong place.
void main() {
  testWidgets('still parks at pinTop after the content above grows', (
    WidgetTester tester,
  ) async {
    final ValueNotifier<double> above = ValueNotifier<double>(200);
    final ValueNotifier<double> pinTop = ValueNotifier<double>(50);
    final ScrollController controller = ScrollController();
    addTearDown(above.dispose);
    addTearDown(pinTop.dispose);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: CustomScrollView(
          controller: controller,
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: ValueListenableBuilder<double>(
                valueListenable: above,
                builder: (_, double h, _) => SizedBox(height: h),
              ),
            ),
            SliverToBoxAdapter(
              child: StickyOnScroll(
                pinTop: pinTop,
                background: Colors.white,
                child: const SizedBox(height: 40, child: Text('bar')),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 3000)),
          ],
        ),
      ),
    );

    // Its sliver has scrolled into the cache area by then, so the finder must
    // not skip it; the translate is what keeps it on screen.
    double barTop() =>
        tester.getTopLeft(find.text('bar', skipOffstage: false)).dy;

    controller.jumpTo(400);
    await tester.pump();
    expect(barTop(), 50);

    // The section above grows by 100 while the bar is pinned.
    above.value = 300;
    await tester.pump();
    controller.jumpTo(420);
    await tester.pump();
    expect(barTop(), 50);

    // Back above the new pin point, it rides with the page again.
    controller.jumpTo(100);
    await tester.pump();
    expect(barTop(), 200);
  });

  // A category tab with fewer stores shortens the list under the pinned bar.
  // At the end of the page that pulls the scroll offset back without telling
  // scroll listeners, and the bar kept the old translation: it floated down
  // over the stores, mid-screen.
  testWidgets('stays at pinTop when the list under it shrinks', (
    WidgetTester tester,
  ) async {
    final ValueNotifier<double> list = ValueNotifier<double>(3000);
    final ValueNotifier<double> pinTop = ValueNotifier<double>(50);
    final ScrollController controller = ScrollController();
    addTearDown(list.dispose);
    addTearDown(pinTop.dispose);
    addTearDown(controller.dispose);

    // Laid out like the All stores section: the list starts under the bar,
    // and the section is the last thing on the page.
    await tester.pumpWidget(
      MaterialApp(
        home: CustomScrollView(
          controller: controller,
          slivers: <Widget>[
            const SliverToBoxAdapter(child: SizedBox(height: 200)),
            SliverToBoxAdapter(
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: ValueListenableBuilder<double>(
                      valueListenable: list,
                      builder: (_, double h, _) => SizedBox(height: h),
                    ),
                  ),
                  StickyOnScroll(
                    pinTop: pinTop,
                    background: Colors.white,
                    child: const SizedBox(height: 40, child: Text('bar')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    double barTop() =>
        tester.getTopLeft(find.text('bar', skipOffstage: false)).dy;

    controller.jumpTo(2300);
    await tester.pump();
    expect(barTop(), 50);

    // The page is now 2640 tall, so the 600 tall screen can scroll to 2040.
    list.value = 2400;
    await tester.pump();
    await tester.pump();
    expect(controller.offset, 2040);
    expect(barTop(), 50);
  });
}
