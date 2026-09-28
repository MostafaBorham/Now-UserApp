import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/utils/app_validator.dart';

/// The digits the user typed after a Saudi phone field's fixed `(05) ` head —
/// the 8 significant digits of a Saudi mobile once the number is complete.
///
/// The head's own `05` must not be counted, which is why the fields do not ask
/// [AppValidator.saudiPhoneToInternational] whether a number is valid: that
/// parser takes any shape a number is stored in, so it reads `(05) 1234567`
/// (seven typed digits) as a complete `0` + `51234567` and the code went to
/// someone else's number.
String phoneFieldSignificantDigits(String text) {
  final String digits = text.replaceAll(RegExp(r'\D'), '');
  return text.startsWith(SaudiPhoneInputFormatter.prefix) &&
          digits.startsWith('05')
      ? digits.substring(2)
      : digits;
}

/// Keeps a Saudi mobile field showing a fixed `(05) ` head in front of whatever
/// the user types: the prefix appears with the first digit and disappears again
/// once every typed digit is deleted, so the placeholder can show through. The
/// 8 significant digits are grouped `XXXX-XXXX`, so a dash slides in after the
/// fourth typed digit — matching the `(05) 1111-2222` hint.
///
/// Shared by the login phone field and the address form, so both show a number
/// the same way. The stored text stays human-readable (`(05) 1234-5678`);
/// callers turn it into the backend's shape themselves.
class SaudiPhoneInputFormatter extends TextInputFormatter {
  const SaudiPhoneInputFormatter();

  static const String prefix = '(05) ';

  /// [text] in the field's own `(05) XXXX-XXXX` shape, from anything a user
  /// types or pastes (a full `05…` / `+966…` number keeps only its 8-digit
  /// tail) or a stored tail being prefilled. Empty when there are no digits.
  static String format(String? text) {
    final String digits = phoneFieldSignificantDigits(text ?? '');
    final String? tail = AppValidator.saudiLocalPhoneTail(digits);
    final String significant =
        tail ?? (digits.length > 8 ? digits.substring(0, 8) : digits);
    if (significant.isEmpty) return '';

    final String grouped = significant.length > 4
        ? '${significant.substring(0, 4)}-${significant.substring(4)}'
        : significant;
    return '$prefix$grouped';
  }

  /// Whether exactly 8 digits follow the field's `(05)` head.
  static bool isComplete(String? text) =>
      phoneFieldSignificantDigits(text ?? '').length == 8;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text = format(newValue.text);
    if (text.isEmpty) return TextEditingValue.empty;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
