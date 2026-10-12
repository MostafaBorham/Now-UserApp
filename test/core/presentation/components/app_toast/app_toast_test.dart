import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast_card.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_themes.dart';

void main() {
  Future<void> showToast(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.getLightModeTheme(),
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () =>
                    AppToast.showSuccess(context, 'Saved', title: 'Done'),
                child: const Text('show'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('show'));
    // The first pump starts the 300 ms entrance, the second finishes it.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AppToastCard), findsOneWidget);
  }

  // The swipe also stops the auto-dismiss timer: one left running would fail
  // the test as a pending timer. A slow drag needs 40% of the card to go, and
  // the card here spans the 800 px test window.
  for (final (String direction, Offset drag) in <(String, Offset)>[
    ('sideways', const Offset(-500, 0)),
    ('down', const Offset(0, 300)),
  ]) {
    testWidgets('a $direction swipe dismisses the toast', (tester) async {
      await showToast(tester);

      await tester.drag(find.byType(AppToastCard), drag);
      await tester.pumpAndSettle();

      expect(find.byType(AppToastCard), findsNothing);
    });
  }
}
