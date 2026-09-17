import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';

/// [formatDouble] used to format money as well, rounding a 12.45 price down to
/// a displayed 12.5 — a cent off what the shopper is charged. Money moved to
/// `formatMoney`; what is left here is the measurement rule, which ratings and
/// distances still want.
void main() {
  test('keeps one decimal and trims a pointless zero', () {
    expect(formatDouble(4.5), 4.5);
    expect(formatDouble(4.0), 4);
    expect(formatDouble(2.46), 2.5);
    expect(formatDouble(null), 0);
  });
}
