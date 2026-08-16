import 'package:flutter/widgets.dart';

/// Elongates Arabic text with Kashida (Tatweel) at the LAST valid join only,
/// e.g. "عطور" -> "عطـــــــور". [count] is the number of tatweel characters
/// inserted at that single join between two connecting letters.
///
/// The input must be Arabic; if it contains no Arabic letters an empty string
/// is returned.
String formatArabicKashida(String text, {int count = 6}) {
  const String tatweel = 'ـ';

  // Letters that do NOT join to the following letter (right-joining only),
  // so a tatweel must never be placed after them.
  const Set<String> nonForwardJoining = {
    'ا', 'أ', 'إ', 'آ', 'د', 'ذ', 'ر', 'ز', 'و', 'ؤ', 'ة', 'ء', 'ى',
  };

  bool isArabicLetter(int code) =>
      (code >= 0x0621 && code <= 0x064A) || (code >= 0x066E && code <= 0x06D3);

  final List<String> chars = text.characters.toList();

  // Must be Arabic, otherwise return an empty string.
  final bool hasArabic =
      chars.any((String c) => isArabicLetter(c.runes.first));
  if (!hasArabic) return '';

  // Find the last valid join (a forward-joining letter followed by a letter).
  int lastJoinIndex = -1;
  for (int i = 0; i < chars.length - 1; i++) {
    final bool currentJoinsForward =
        isArabicLetter(chars[i].runes.first) &&
        !nonForwardJoining.contains(chars[i]);
    final bool nextIsLetter = isArabicLetter(chars[i + 1].runes.first);

    if (currentJoinsForward && nextIsLetter) {
      lastJoinIndex = i;
    }
  }

  if (lastJoinIndex == -1) return text;

  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < chars.length; i++) {
    buffer.write(chars[i]);
    if (i == lastJoinIndex) {
      buffer.write(tatweel * count);
    }
  }

  return buffer.toString();
}
