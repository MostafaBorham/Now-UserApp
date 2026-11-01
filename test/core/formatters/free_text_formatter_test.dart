import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/formatters/free_text_formatter.dart';

void main() {
  group('isReadableText', () {
    test('accepts real comments in either language', () {
      for (final String comment in <String>[
        '',
        '   ',
        'ok',
        'Fresh and well packed!',
        'Good 5/5',
        'المنتج ممتاز والتغليف جيد',
        'مَرْحَبًا، شكرًا',
        'Very very very good',
      ]) {
        expect(isReadableText(comment), isTrue, reason: comment);
      }
    });

    test('refuses symbols, digits and repeats', () {
      for (final String comment in <String>[
        '---',
        '12345',
        'a b c',
        '!!! ... ??? ok',
        'hahahaha',
        'abcabcabcabc',
        'good good good good good',
      ]) {
        expect(isReadableText(comment), isFalse, reason: comment);
      }
    });
  });

  group('freeTextInputFormatters', () {
    String type(String text) => freeTextInputFormatters
        .fold(
          TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          ),
          (TextEditingValue value, TextInputFormatter formatter) =>
              formatter.formatEditUpdate(TextEditingValue.empty, value),
        )
        .text;

    test('drops symbols, emoji and tatweel', () {
      expect(type('-----***+++###'), '---');
      expect(type('great 👍 <b>'), 'great  b');
      expect(type('عطـــور'), 'عطور');
    });

    test('caps runs at three', () {
      expect(type('soooooo good'), 'sooo good');
      expect(type('!?!?!?'), '!?!');
      expect(type('a\n\n\n\n\nb'), 'a\n\n\nb');
      expect(type('10000 ١١١١١'), '10000 ١١١١١');
    });

    test('keeps everyday punctuation in both languages', () {
      const String text =
          'Isn’t it “fresh”? (yes) – 50%; ما رأيك؟ جيد، ٢٫٥ كيلو';
      expect(type(text), text);
    });
  });
}
