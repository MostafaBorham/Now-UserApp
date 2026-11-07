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
  const String prefix = SaudiPhoneInputFormatter.prefix;
  final String significant = text.startsWith(prefix)
      ? text.substring(prefix.length)
      : text;
  return significant.replaceAll(RegExp(r'\D'), '');
}

/// Keeps a Saudi mobile field showing a fixed `(05) ` head in front of whatever
/// the user types: the prefix appears with the first digit and disappears again
/// once every typed digit is deleted, so the placeholder can show through.
///
/// By default the digits are grouped as `XXXX-XXXX`.
class SaudiPhoneInputFormatter extends TextInputFormatter {
  const SaudiPhoneInputFormatter({this.groupDigits = true});

  static const String prefix = '(05) ';

  final bool groupDigits;

  /// [text] in the field's own `(05) XXXX-XXXX` shape, from anything a user
  /// types or pastes (a full `05…` / `+966…` number keeps only its 8-digit
  /// tail) or a stored tail being prefilled. Empty when there are no digits.
  static String format(String? text, {bool groupDigits = true}) {
    final String digits = phoneFieldSignificantDigits(text ?? '');
    final String? tail = AppValidator.saudiLocalPhoneTail(digits);
    final String significant =
        tail ?? (digits.length > 8 ? digits.substring(0, 8) : digits);
    if (significant.isEmpty) return '';

    final String grouped = groupDigits && significant.length > 4
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
    final String text = format(newValue.text, groupDigits: groupDigits);
    if (text.isEmpty) return TextEditingValue.empty;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
