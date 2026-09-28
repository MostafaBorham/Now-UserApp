import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/formatters/saudi_phone_input_formatter.dart';
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
  testWidgets('phone input is formatted like the phone verification field', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        AddressField(
          hintText: 'Mobile number',
          controller: controller,
          textDirection: TextDirection.ltr,
          inputFormatters: const [SaudiPhoneInputFormatter()],
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '123456789');

    expect(controller.text, '(05) 1234-5678');
  });

  testWidgets('left-to-right input aligns to the start edge in Arabic', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AddressField(
          hintText: 'رقم الجوال',
          textDirection: TextDirection.ltr,
        ),
        direction: TextDirection.rtl,
      ),
    );

    final TextField field = tester.widget(find.byType(TextField));
    expect(field.textDirection, TextDirection.ltr);
    expect(field.textAlign, TextAlign.right);
  });

  testWidgets('field without a text direction follows the locale', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const AddressField(hintText: 'Building')));

    final TextField field = tester.widget(find.byType(TextField));
    expect(field.textDirection, isNull);
    expect(field.textAlign, TextAlign.start);
  });
}
