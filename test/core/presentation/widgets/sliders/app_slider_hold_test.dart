import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_themes.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';

// BUG-012: a finger resting on a carousel didn't hold it — it slid on mid-hold.
void main() {
  testWidgets('holds while pressed, moves again once released', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.getLightModeTheme(),
        home: Scaffold(
          body: AppSlider(
            itemAspectRatio: 3,
            sliderItems: <Widget>[
              // A child that wins the gesture arena mid-hold (as a long press,
              // or the page's own vertical drag, does) cancelled the
              // carousel's pause.
              for (int i = 0; i < 3; i++)
                GestureDetector(onLongPress: () {}, child: Text('slide $i')),
            ],
          ),
        ),
      ),
    );
    double page() =>
        tester.widget<PageView>(find.byType(PageView)).controller!.page!;
    final double start = page();

    final TestGesture finger = await tester.startGesture(
      tester.getCenter(find.byType(PageView)),
    );
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(seconds: 1));
    expect(page(), start);

    await finger.up();
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(page(), isNot(start));
  });
}
