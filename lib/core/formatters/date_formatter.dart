import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

String formatLocalizedDate(
    BuildContext context,
    String? dateString,
    ) {
  if (dateString == null || dateString.trim().isEmpty) {
    return 'NoDate';
  }

  final parsedDate = DateTime.tryParse(dateString);

  if (parsedDate == null) {
    return '';
  }

  final utcDate = parsedDate.toUtc();
  final languageCode = context.locale.languageCode;

  return DateFormat.yMMMMd(languageCode).format(utcDate);
}