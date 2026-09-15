import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/my_app.dart';

void main() {
  testWidgets('Widget Test', (WidgetTester tester) async {

    await tester.pumpWidget(const NowUserApp());


    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);


    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();


    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
