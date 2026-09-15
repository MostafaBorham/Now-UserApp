import 'package:flutter/widgets.dart';

String formatArabicKashida(String text, {int count = 6}) {
  const String tatweel = 'ـ';

  const Set<String> nonForwardJoining = {
    'ا', 'أ', 'إ', 'آ', 'د', 'ذ', 'ر', 'ز', 'و', 'ؤ', 'ة', 'ء', 'ى',
  };

  bool isArabicLetter(int code) =>
      (code >= 0x0621 && code <= 0x064A) || (code >= 0x066E && code <= 0x06D3);

  final List<String> chars = text.characters.toList();

  final bool hasArabic =
      chars.any((String c) => isArabicLetter(c.runes.first));
  if (!hasArabic) return text;

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
