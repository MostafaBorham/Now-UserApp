import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/screens/order_rating_screen.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/order_rating/rating_comment_field.dart';

void main() {
  group('ratingSubmitBlocker', () {
    test('one starred target is enough', () {
      expect(
        ratingSubmitBlocker(<({int rating, String comment})>[
          (rating: 4, comment: ''),
          (rating: 0, comment: ''),
          (rating: 0, comment: ''),
        ]),
        isNull,
      );
    });

    test('nothing starred cannot be sent', () {
      expect(
        ratingSubmitBlocker(<({int rating, String comment})>[
          (rating: 0, comment: ''),
          (rating: 0, comment: '   '),
        ]),
        LangKeys.ratingRequiredKey,
      );
    });

    test('a comment without its own stars blocks the send', () {
      // The backend takes no comment without a rate, so sending would drop it.
      expect(
        ratingSubmitBlocker(<({int rating, String comment})>[
          (rating: 5, comment: 'great'),
          (rating: 0, comment: 'late'),
        ]),
        LangKeys.ratingCommentNeedsStarsKey,
      );
      expect(
        ratingSubmitBlocker(<({int rating, String comment})>[
          (rating: 0, comment: 'late'),
        ]),
        LangKeys.ratingCommentNeedsStarsKey,
      );
    });

    test('a comment that is not words blocks the send', () {
      expect(
        ratingSubmitBlocker(<({int rating, String comment})>[
          (rating: 5, comment: 'great'),
          (rating: 4, comment: '- - - - - ok'),
        ]),
        LangKeys.ratingCommentUnreadableKey,
      );
    });
  });

  group('RatingCommentField.isReadable', () {
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
        expect(RatingCommentField.isReadable(comment), isTrue, reason: comment);
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
        expect(
          RatingCommentField.isReadable(comment),
          isFalse,
          reason: comment,
        );
      }
    });
  });

  group('RatingCommentField.inputFormatters', () {
    String type(String text) => RatingCommentField.inputFormatters
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
      const String text = 'Isn’t it “fresh”? (yes) – 50%; ما رأيك؟ جيد، ٢٫٥ كيلو';
      expect(type(text), text);
    });
  });
}
