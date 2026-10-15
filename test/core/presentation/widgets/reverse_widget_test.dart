import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';

// The mirror used to be dropped when not needed, so a language switch changed
// the tree's shape and remounted the child: the Home header's animated
// motorcycle reloaded, blinking out and restarting.
void main() {
  testWidgets('keeps its child mounted when the mirroring flips', (
    WidgetTester tester,
  ) async {
    final ValueNotifier<bool> reverse = ValueNotifier<bool>(false);
    addTearDown(reverse.dispose);
    const Key probe = ValueKey<String>('probe');

    await tester.pumpWidget(
      ValueListenableBuilder<bool>(
        valueListenable: reverse,
        builder: (_, bool r, _) =>
            ReverseWidget(applyReverse: r, child: const SizedBox(key: probe)),
      ),
    );
    final Element before = tester.element(find.byKey(probe));

    reverse.value = true;
    await tester.pump();
    expect(tester.element(find.byKey(probe)), same(before));

    reverse.value = false;
    await tester.pump();
    expect(tester.element(find.byKey(probe)), same(before));
  });
}
