import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/utils/app_validator.dart';

void main() {
  group('saudiLocalPhoneTail', () {
    test('keeps the 8 digits that follow the 05 prefix', () {
      expect(AppValidator.saudiLocalPhoneTail('12345678'), '12345678');
    });

    test('reduces a number that already carries its own prefix', () {
      for (final String raw in <String>[
        '0512345678',
        '512345678',
        '966512345678',
        '+966512345678',
        '+966 51 234 5678',
        '+966-51-234-5678',
      ]) {
        expect(
          AppValidator.saudiLocalPhoneTail(raw),
          '12345678',
          reason: '"$raw" should reduce to the tail 12345678',
        );
      }
    });

    test('treats 8 digits as a tail even when they start like a prefix', () {
      // The tail of 0505123456 — not a duplicated "05".
      expect(AppValidator.saudiLocalPhoneTail('05123456'), '05123456');
    });

    test('rejects anything that cannot be a Saudi mobile number', () {
      for (final String? raw in <String?>[
        null,
        '',
        '1234',
        '05000000000', // 11 digits
        '9665123456', // 10 digits behind a country code
        'abc',
      ]) {
        expect(
          AppValidator.saudiLocalPhoneTail(raw),
          isNull,
          reason: '"$raw" should not produce a tail',
        );
      }
    });
  });

  // The login flow identifies a user by the exact phone string it sends, so this
  // rule must keep accepting the international format only.
  test('isValidSaudiPhone still accepts +9665XXXXXXXX and only that', () {
    expect(AppValidator.isValidSaudiPhone('+966512345678'), isTrue);
    expect(AppValidator.isValidSaudiPhone('+966 51 234 5678'), isTrue);
    expect(AppValidator.isValidSaudiPhone('0512345678'), isFalse);
  });
}
