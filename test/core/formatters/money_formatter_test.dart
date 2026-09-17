import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';

void main() {
  group('parseSarToHalalas', () {
    test('reads whole riyals', () {
      expect(parseSarToHalalas('300'), 30000);
      expect(parseSarToHalalas('1'), 100);
      expect(parseSarToHalalas('0'), 0);
    });

    test('reads one fraction digit as tenths, not hundredths', () {
      // The bug this guards: "10.5" charged as 11 (or as 10.05).
      expect(parseSarToHalalas('10.5'), 1050);
    });

    test('reads two fraction digits exactly', () {
      expect(parseSarToHalalas('10.55'), 1055);
      expect(parseSarToHalalas('10.05'), 1005);
      expect(parseSarToHalalas('0.01'), 1);
    });

    test('tolerates surrounding whitespace', () {
      expect(parseSarToHalalas('  12.30  '), 1230);
    });

    test('rejects anything the endpoint would refuse', () {
      for (final String input in <String>[
        '',
        '   ',
        'abc',
        '-5',
        '+5',
        '10.555',
        '1,000',
        '1e3',
        '10.',
        '.5',
        '١٠',
      ]) {
        expect(parseSarToHalalas(input), isNull, reason: 'input: "$input"');
      }
    });
  });

  group('formatHalalasAsSar', () {
    test('always emits two fraction digits', () {
      expect(formatHalalasAsSar(30000), '300.00');
      expect(formatHalalasAsSar(1050), '10.50');
      expect(formatHalalasAsSar(1005), '10.05');
      expect(formatHalalasAsSar(1), '0.01');
      expect(formatHalalasAsSar(0), '0.00');
    });
  });

  group('sarDoubleToHalalas', () {
    test('survives the binary representation of a server amount', () {
      // 10.5 * 100 is 1050.0000000000002 in IEEE 754.
      expect(sarDoubleToHalalas(10.5), 1050);
      expect(sarDoubleToHalalas(300), 30000);
      expect(sarDoubleToHalalas(0.07), 7);
    });
  });

  test('typed text round-trips through the wire format unchanged', () {
    for (final String typed in <String>['1', '10.5', '10.55', '4999.99']) {
      final int? halalas = parseSarToHalalas(typed);
      expect(halalas, isNotNull, reason: 'input: "$typed"');
      expect(parseSarToHalalas(formatHalalasAsSar(halalas!)), halalas);
    }
  });

  group('formatMoney', () {
    test('always shows two decimals', () {
      expect(formatMoney(12), '12.00');
      expect(formatMoney(12.5), '12.50');
      expect(formatMoney(0), '0.00');
    });

    test('does not round a cent away', () {
      // The bug this guards: prices went through `formatDouble`, which rounds
      // to one decimal, so a 12.45 item was displayed as 12.5.
      expect(formatMoney(12.45), '12.45');
      expect(formatMoney(99.99), '99.99');
    });

    test('rounds beyond two decimals rather than printing them', () {
      // Cart totals used to reach the screen as raw doubles: `12.456`, `0.0`.
      expect(formatMoney(12.456), '12.46');
      expect(formatMoney(12.454), '12.45');
    });

    test('treats a missing amount as zero', () {
      expect(formatMoney(null), '0.00');
    });
  });
}
