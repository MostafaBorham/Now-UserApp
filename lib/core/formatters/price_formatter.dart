import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';

/// Product prices omit trailing zeroes in the redesigned info card.
String formatTrimmedPrice(double? value) =>
    formatMoney(value).replaceFirst(RegExp(r'\.?0+$'), '');
