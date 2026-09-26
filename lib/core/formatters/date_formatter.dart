import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

String formatLocalizedDate(BuildContext context, String? dateString) {
  if (dateString == null || dateString.trim().isEmpty) {
    return '';
  }

  final parsedDate = DateTime.tryParse(dateString);

  if (parsedDate == null) {
    return '';
  }

  // `.toLocal()`, never `.toUtc()`: an ISO string carrying a timezone (`Z` or
  // an offset) is parsed into a UTC DateTime, and formatting that prints the
  // UTC wall clock — which in UTC+3 shows the previous day for anything between
  // local midnight and 03:00, and shows a date-only value a day early always.
  final localDate = parsedDate.toLocal();
  final languageCode = context.locale.languageCode;

  return DateFormat.yMMMMd(languageCode).format(localDate);
}

String? formatLocalizedDateOnly(BuildContext context, String? dateString) {
  if (dateString == null || dateString.trim().isEmpty) {
    return null;
  }

  final parsedDate = DateTime.tryParse(dateString);

  if (parsedDate == null) {
    return null;
  }

  return DateFormat.yMMMMd(context.locale.languageCode).format(parsedDate);
}

String formatLocalizedNumericDate(BuildContext context, String? dateString) {
  if (dateString == null || dateString.trim().isEmpty) {
    return '';
  }

  final parsedDate = DateTime.tryParse(dateString);

  if (parsedDate == null) {
    return '';
  }

  // See [formatLocalizedDate] for why this is `.toLocal()`.
  final localDate = parsedDate.toLocal();
  final languageCode = context.locale.languageCode;
  final formatted = DateFormat('dd-MM-yyyy', languageCode).format(localDate);

  return languageCode == 'ar' ? _toArabicIndicDigits(formatted) : formatted;
}

/// Numeric date plus 24-hour time, e.g. `dd-MM-yyyy · HH:mm`. Used where a row
/// needs the transaction hour (wallet history), not just the day.
String formatLocalizedNumericDateTime(BuildContext context, String? dateString) {
  if (dateString == null || dateString.trim().isEmpty) {
    return '';
  }

  final parsedDate = DateTime.tryParse(dateString);

  if (parsedDate == null) {
    return '';
  }

  // See [formatLocalizedDate] for why this is `.toLocal()`.
  final localDate = parsedDate.toLocal();
  final languageCode = context.locale.languageCode;
  final formatted =
      DateFormat('dd-MM-yyyy · HH:mm', languageCode).format(localDate);

  return languageCode == 'ar' ? _toArabicIndicDigits(formatted) : formatted;
}

const List<String> _arabicIndicDigits = [
  '٠',
  '١',
  '٢',
  '٣',
  '٤',
  '٥',
  '٦',
  '٧',
  '٨',
  '٩',
];

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
