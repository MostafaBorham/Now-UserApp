import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/lists/infinite_auto_scroll_list.dart';

// BUG-011: two or three offers used to loop, repeating the same products side
// by side. Only a strip that overflows moves.
void main() {
  Future<int?> childCount(WidgetTester tester, int items) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 120,
          child: InfiniteAutoScrollList(
            itemCount: items,
            itemWidth: 100,
            separatorWidth: 10,
            itemBuilder: (_, int i) => Text('$i'),
          ),
        ),
      ),
    );
    await tester.pump();
    final SliverChildDelegate delegate = tester
        .widget<ListView>(find.byType(ListView))
        .childrenDelegate;
    return (delegate as SliverChildBuilderDelegate).childCount;
  }

  testWidgets('a row that fits stays still', (WidgetTester tester) async {
    expect(await childCount(tester, 3), 3);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('a row that overflows loops', (WidgetTester tester) async {
    expect(await childCount(tester, 5), greaterThan(5));
    expect(tester.binding.hasScheduledFrame, isTrue);
  });
}
