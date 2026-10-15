import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/input_direction.dart';

void main() {
  group('resolveInputDirection', () {
    test('null and empty text keep the locale direction', () {
      expect(resolveInputDirection(null), isNull);
      expect(resolveInputDirection(''), isNull);
    });

    test('digits, spaces and punctuation are not strong', () {
      expect(resolveInputDirection('123'), isNull);
      expect(resolveInputDirection(' 50/50 '), isNull);
      expect(resolveInputDirection('،؟!'), isNull);
    });

    test('Arabic-Indic digits are weak, not RTL', () {
      expect(resolveInputDirection('٠١٢٣٤٥٦٧٨٩'), isNull);
      expect(resolveInputDirection('۵۰'), isNull);
    });

    test('Latin letters read left-to-right', () {
      expect(resolveInputDirection('Hello'), TextDirection.ltr);
      expect(resolveInputDirection('Émile'), TextDirection.ltr);
    });

    test('Arabic letters read right-to-left', () {
      expect(resolveInputDirection('مرحبا'), TextDirection.rtl);
      expect(resolveInputDirection('أهلاً'), TextDirection.rtl);
    });

    test('the first strong character decides', () {
      expect(resolveInputDirection('hello مرحبا'), TextDirection.ltr);
      expect(resolveInputDirection('مرحبا hello'), TextDirection.rtl);
      expect(resolveInputDirection('٥٠ off! مرحبا'), TextDirection.ltr);
    });
  });

  group('InputDirectionBuilder', () {
    Widget wrap(TextEditingController controller, TextDirection ambient) {
      return MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: ambient,
            child: InputDirectionBuilder(
              controller: controller,
              builder: (context, direction) => TextField(
                textDirection: direction,
                textInputAction: TextInputAction.done,
              ),
            ),
          ),
        ),
      );
    }

    TextDirection? fieldDirection(WidgetTester tester) =>
        tester.widget<TextField>(find.byType(TextField)).textDirection;

    testWidgets('empty field stays on the ambient direction', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(wrap(controller, TextDirection.rtl));
      expect(fieldDirection(tester), isNull);
      await tester.pumpWidget(wrap(controller, TextDirection.ltr));
      expect(fieldDirection(tester), isNull);
      controller.dispose();
    });

    testWidgets('flips between LTR and RTL as the typed language changes', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(wrap(controller, TextDirection.ltr));

      controller.text = 'Hello';
      await tester.pump();
      expect(fieldDirection(tester), TextDirection.ltr);

      controller.text = 'مرحبا';
      await tester.pump();
      expect(fieldDirection(tester), TextDirection.rtl);

      // Weak-only text (digits) falls back to the locale's direction.
      controller.text = '123';
      await tester.pump();
      expect(fieldDirection(tester), isNull);

      controller.dispose();
    });
  });
}
