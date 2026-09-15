import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/address/presentation/widgets/address_field.dart';



Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) {
  return MaterialApp(
    home: Directionality(
      textDirection: direction,
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('prefix is visible while the field is empty and unfocused', (
    WidgetTester tester,
  ) async {


    await tester.pumpWidget(
      _host(const AddressField(hintText: 'Mobile number', prefixText: '05')),
    );

    expect(find.text('05'), findsOneWidget);
  });

  testWidgets('prefix stays left of the digits in a right-to-left locale', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AddressField(hintText: 'رقم الجوال', prefixText: '05'),
        direction: TextDirection.rtl,
      ),
    );

    expect(
      tester.getCenter(find.text('05')).dx,
      lessThan(tester.getCenter(find.byType(TextField)).dx),
    );
  });

  testWidgets('field without a prefix is unchanged', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const AddressField(hintText: 'Building')));

    expect(find.text('05'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });
}
