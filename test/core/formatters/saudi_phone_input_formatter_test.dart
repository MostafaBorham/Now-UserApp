import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/formatters/saudi_phone_input_formatter.dart';

void main() {
  const SaudiPhoneInputFormatter formatter = SaudiPhoneInputFormatter();

  String type(String text) => formatter
      .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text))
      .text;

  group('SaudiPhoneInputFormatter', () {
    test('adds the (05) head and groups the digits', () {
      expect(type('1'), '(05) 1');
      expect(type('12345'), '(05) 1234-5');
      expect(type('12345678'), '(05) 1234-5678');
    });

    test('caps the number at 8 significant digits', () {
      expect(type('(05) 1234-56789'), '(05) 1234-5678');
    });

    test('strips a pasted local or international head', () {
      expect(type('0512345678'), '(05) 1234-5678');
      expect(type('+966512345678'), '(05) 1234-5678');
    });

    test('clears to empty when every digit is deleted', () {
      expect(type('(05) '), '');
    });

    test('format prefills a stored tail', () {
      expect(SaudiPhoneInputFormatter.format('12345678'), '(05) 1234-5678');
      expect(SaudiPhoneInputFormatter.format(null), '');
    });

    test('isComplete needs all 8 significant digits', () {
      expect(SaudiPhoneInputFormatter.isComplete('(05) 1234-5678'), isTrue);
      expect(SaudiPhoneInputFormatter.isComplete('(05) 0512-3456'), isTrue);
      expect(SaudiPhoneInputFormatter.isComplete('(05) 1234-567'), isFalse);
      expect(SaudiPhoneInputFormatter.isComplete(''), isFalse);
    });

    test(
      'login shows an ungrouped number and clears the prefix when empty',
      () {
        const formatter = SaudiPhoneInputFormatter(groupDigits: false);

        String edit(String text) => formatter
            .formatEditUpdate(
              TextEditingValue.empty,
              TextEditingValue(text: text),
            )
            .text;

        expect(edit('1'), '(05) 1');
        expect(edit('(05) 12345678'), '(05) 12345678');
        expect(edit('+966512345678'), '(05) 12345678');
        expect(edit('(05) '), '');
        expect(SaudiPhoneInputFormatter.isComplete('(05) 1234567'), isFalse);
        expect(SaudiPhoneInputFormatter.isComplete('(05) 12345678'), isTrue);
      },
    );
  });
}
