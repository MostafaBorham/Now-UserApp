import 'package:flutter/services.dart';

/// What a free-text box (a rating comment, a complaint) lets through, typed or
/// pasted, applied in order:
///
/// 1. Letters of any script with their marks (Arabic diacritics), digits,
///    spaces, line breaks and everyday punctuation — Arabic marks and the
///    curly quotes and dashes iOS substitutes included. Symbols (`*`, `+`,
///    `#`, `_`, …), emoji and the decorative tatweel never reach the box.
/// 2. The same character at most three times in a row: `-------` stays
///    `---`, `حلووووو` stays `حلووو`. Digits are exempt, so `10000` is kept.
/// 3. At most three punctuation marks in a row: `!?!?!?` stays `!?!`.
final List<TextInputFormatter> freeTextInputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(
    RegExp(
      r'''(?!ـ)[\p{L}\p{M}\p{Nd} \n.,!?'"()\-:;/%&،؛؟٪٫٬…‘’“”«»–—]''',
      unicode: true,
    ),
  ),
  FilteringTextInputFormatter.deny(RegExp(r'(\P{Nd})(?=\1{3})', unicode: true)),
  FilteringTextInputFormatter.deny(
    RegExp(
      r'(?<=[^\p{L}\p{M}\p{Nd}\s]{3})[^\p{L}\p{M}\p{Nd}\s]',
      unicode: true,
    ),
  ),
];

final RegExp _letter = RegExp(r'[\p{L}\p{M}]', unicode: true);
final RegExp _word = RegExp(r'\p{L}\p{M}*\p{L}', unicode: true);
final RegExp _repeatedChunk = RegExp(r'(.{2,}?)\1{3}', unicode: true);

/// Whether [text] reads as words rather than filler — what
/// [freeTextInputFormatters] alone can't stop. Empty text passes (callers that
/// require it check that themselves); otherwise it needs a word of two letters
/// or more, letters must make up at least half of what isn't a space
/// (`- - - - ok` fails), and no stretch of it may repeat four times running
/// (`hahahaha`, `abcabcabcabc`).
bool isReadableText(String text) {
  final String trimmed = text.trim();
  if (trimmed.isEmpty) return true;
  final int visible = trimmed.replaceAll(RegExp(r'\s'), '').runes.length;
  return _word.hasMatch(trimmed) &&
      _letter.allMatches(trimmed).length * 2 >= visible &&
      !_repeatedChunk.hasMatch(trimmed);
}
