import 'package:flutter/services.dart';

/// What a name box lets through: letters of any script with their marks
/// (Arabic diacritics), spaces, hyphens and apostrophes. Digits, symbols and
/// emoji never reach the field.
final TextInputFormatter nameInputFormatter = FilteringTextInputFormatter.allow(
  RegExp(r"[\p{L}\p{M} '\-]", unicode: true),
);
