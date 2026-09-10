import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Formats a raw API timestamp as a localized date (Arabic/English month names)
/// following the current app locale. Returns an empty string when the value is
/// null, empty or unparseable, so callers can use it directly — display the
/// result as-is, or guard visibility with `.isNotEmpty` — without re-checking or
/// re-parsing the timestamp themselves.
String formatLocalizedDate(
    BuildContext context,
    String? dateString,
    ) {
  if (dateString == null || dateString.trim().isEmpty) {
    return '';
  }

  final parsedDate = DateTime.tryParse(dateString);

  if (parsedDate == null) {
    return '';
  }

  final utcDate = parsedDate.toUtc();
  final languageCode = context.locale.languageCode;

  return DateFormat.yMMMMd(languageCode).format(utcDate);
}

/// Formats a raw API timestamp as a localized numeric `dd-MM-yyyy` date
/// (e.g. `10-04-2026`, and `١٠-٠٤-٢٠٢٦` with Arabic-Indic digits under `ar`),
/// following the current app locale. Like [formatLocalizedDate] it returns an
/// empty string when the value is null, empty or unparseable, so callers can use
/// it directly — display the result as-is, or guard visibility with `.isNotEmpty`
/// — without re-checking or re-parsing the timestamp themselves.
///
/// intl's pattern formatter keeps Latin digits even for the Arabic locale, so
/// the digits are converted to Arabic-Indic explicitly when the app is Arabic.
String formatLocalizedNumericDate(
    BuildContext context,
    String? dateString,
    ) {
  if (dateString == null || dateString.trim().isEmpty) {
    return '';
  }

  final parsedDate = DateTime.tryParse(dateString);

  if (parsedDate == null) {
    return '';
  }

  final utcDate = parsedDate.toUtc();
  final languageCode = context.locale.languageCode;
  final formatted = DateFormat('dd-MM-yyyy', languageCode).format(utcDate);

  return languageCode == 'ar' ? _toArabicIndicDigits(formatted) : formatted;
}

/// Arabic-Indic digits ٠١٢٣٤٥٦٧٨٩ indexed by their Latin value 0–9.
const List<String> _arabicIndicDigits = [
  '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩',
];

/// Replaces the Latin digits 0–9 in [input] with their Arabic-Indic equivalents,
/// leaving every other character (separators, letters) untouched.
String _toArabicIndicDigits(String input) {
  final StringBuffer buffer = StringBuffer();
  for (final int codeUnit in input.codeUnits) {
    if (codeUnit >= 0x30 && codeUnit <= 0x39) {
      buffer.write(_arabicIndicDigits[codeUnit - 0x30]);
    } else {
      buffer.writeCharCode(codeUnit);
    }
  }
  return buffer.toString();
}