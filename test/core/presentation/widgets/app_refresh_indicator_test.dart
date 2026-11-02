import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/dio/deduping_dio.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';

void main() {
  testWidgets('a pull right after a refresh does nothing until the window ends',
      (WidgetTester tester) async {
    int refreshes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: AppRefreshIndicator(
          onRefresh: () async {
            refreshes++;
          },
          child: ListView(
            children: const <Widget>[SizedBox(height: 2000)],
          ),
        ),
      ),
    );

    /// Pulls down, notes whether the spinner showed, then lets go.
    Future<bool> pull() async {
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      for (int i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(0, 30));
        await tester.pump();
      }
      final bool spinnerShown = find
          .byType(RefreshProgressIndicator)
          .evaluate()
          .isNotEmpty;
      await gesture.up();
      await tester.pumpAndSettle();
      return spinnerShown;
    }

    expect(await pull(), isTrue);
    expect(refreshes, 1);

    expect(await pull(), isFalse);
    expect(refreshes, 1);

    await tester.pump(DedupingDio.reuseWindow);
    expect(await pull(), isTrue);
    expect(refreshes, 2);
  });
}
