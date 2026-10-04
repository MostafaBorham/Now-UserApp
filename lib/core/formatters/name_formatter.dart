import 'package:flutter/services.dart';

/// What a name box lets through: letters of any script with their marks
/// (Arabic diacritics), spaces, hyphens and apostrophes. Digits, symbols and
/// emoji never reach the field.
final TextInputFormatter nameInputFormatter = FilteringTextInputFormatter.allow(
  RegExp(r"[\p{L}\p{M} '\-]", unicode: true),
);

/// Joins the design's two name boxes into the single `full_name` the API
/// takes. Blank parts drop out, so a one-word name stays one word and never
/// carries a stray separator.
String joinFullName(String first, String last) => <String>[
  first.trim(),
  last.trim(),
].where((String part) => part.isNotEmpty).join(' ');

/// Splits a stored `full_name` back into the two boxes: the first word, and
/// everything after it. The split is only for display — [joinFullName] of the
/// parts gives the name back, so an untouched name saves unchanged.
({String first, String last}) splitFullName(String? fullName) {
  final String trimmed = (fullName ?? '').trim();
  final int separator = trimmed.indexOf(RegExp(r'\s'));
  if (separator == -1) return (first: trimmed, last: '');
  return (
    first: trimmed.substring(0, separator),
    last: trimmed.substring(separator).trim(),
  );
}
