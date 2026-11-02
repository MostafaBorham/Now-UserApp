import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/wave_pinned_header_sliver.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/top_wave_clipper.dart';

void main() {
  testWidgets('pins below the wave and hides what scrolls under its strip', (
    WidgetTester tester,
  ) async {
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);
    final List<int> tapped = <int>[];
    const Key header = Key('header');

    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            height: 600,
            child: CustomScrollView(
              controller: controller,
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 300)),
                const WavePinnedHeaderSliver(
                  color: Colors.white,
                  child: SizedBox(key: header, height: 50),
                ),
                SliverList.builder(
                  itemCount: 40,
                  itemBuilder: (BuildContext context, int i) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => tapped.add(i),
                    child: const SizedBox(height: 100),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    double headerTop() => tester.getTopLeft(find.byKey(header)).dy;
    final double depth = TopWaveClipper.depthFor(400);

    // At rest it sits in the scroll, below the content before it.
    expect(headerTop(), 300);

    // Its scroll position is already inside the wave: held at the wave's foot.
    controller.jumpTo(280);
    await tester.pump();
    expect(headerTop(), moreOrLessEquals(depth));

    // Scrolled well past: still there, and the strip above it takes the tap
    // meant for the hidden item behind it.
    controller.jumpTo(800);
    await tester.pump();
    expect(headerTop(), moreOrLessEquals(depth));
    await tester.tapAt(const Offset(200, 10));
    expect(tapped, isEmpty);
    await tester.tapAt(const Offset(200, 300));
    expect(tapped, isNotEmpty);
  });
}
