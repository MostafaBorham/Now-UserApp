import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';






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


const List<String> _arabicIndicDigits = [
  '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩',
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
