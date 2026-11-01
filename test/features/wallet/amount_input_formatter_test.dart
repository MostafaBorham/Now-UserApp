import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/money_amount_picker.dart';

/// The custom top-up amount takes numbers only and can't be typed past the
/// maximum (5000.00 here).
void main() {
  final AmountInputFormatter formatter = AmountInputFormatter(500000);

  String type(String oldText, String newText) => formatter
      .formatEditUpdate(
        TextEditingValue(text: oldText),
        TextEditingValue(text: newText),
      )
      .text;

  test('keeps digits, one point and two decimals up to the maximum', () {
    expect(type('500', '5000'), '5000');
    expect(type('5000', '5000.'), '5000.');
    expect(type('5000.', '5000.0'), '5000.0');
    expect(type('12.5', '12.50'), '12.50');
    expect(type('5', ''), '');
  });

  test('refuses the keystroke that would pass the maximum', () {
    expect(type('5000', '50001'), '5000');
    expect(type('5000.', '5000.1'), '5000.');
    expect(type('1111', '11111'), '1111');
  });

  test('refuses anything that is not a number', () {
    for (final String bad in <String>[
      '5a',
      '5 ',
      '5,',
      '-5',
      '+5',
      '5.5.',
      '5.555',
      '.',
      '١٠',
    ]) {
      expect(type('5', bad), '5', reason: 'typed "$bad"');
    }
  });
}
