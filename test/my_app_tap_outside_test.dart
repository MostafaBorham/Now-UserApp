import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/my_app.dart';

void main() {
  final FocusNode focusNode = FocusNode();
  int recentTaps = 0;

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      builder: (_, Widget? child) =>
          Actions(actions: tapOutsideUnfocusActions, child: child!),
      home: Scaffold(
        body: Column(
          children: <Widget>[
            TextField(focusNode: focusNode),
            // Stands in for a search field's recents panel.
            TextFieldTapRegion(
              child: TextButton(
                onPressed: () => recentTaps++,
                child: const Text('recent'),
              ),
            ),
            const Text('outside'),
          ],
        ),
      ),
    ),
  );

  testWidgets('a touch outside the field unfocuses it', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.tap(find.text('outside'));
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);
  });

  testWidgets('a touch in a TextFieldTapRegion keeps focus', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(TextField));
    await tester.pump();

    await tester.tap(find.text('recent'));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);
    expect(recentTaps, 1);
  });
}
