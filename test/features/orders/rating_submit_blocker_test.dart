import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/screens/order_rating_screen.dart';

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
  });
}
