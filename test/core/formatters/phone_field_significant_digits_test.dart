import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/formatters/saudi_phone_input_formatter.dart';

void main() {
  group('phoneFieldSignificantDigits', () {
    test("doesn't count the field's own (05) head", () {
      expect(phoneFieldSignificantDigits('(05) 1234-5678'), '12345678');
      expect(phoneFieldSignificantDigits('(05) 12345678'), '12345678');
    });

    test('an unfinished number stays short, so Continue stays off', () {
      // Each of these used to pass the generic parser and send the code to a
      // different, complete number.
      for (final String text in <String>[
        '(05) 1234567',
        '(05) 5123456',
        '(05) 512345',
      ]) {
        expect(
          phoneFieldSignificantDigits(text).length,
          lessThan(8),
          reason: '"$text" is not a complete number',
        );
      }
    });

    test('an empty field has no digits', () {
      expect(phoneFieldSignificantDigits(''), isEmpty);
    });
  });
}
