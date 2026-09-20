import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_variant_pills.dart';

import '../../../../helpers/categories_test_harness.dart';

/// A wrong hex draws a wrong swatch and a thrown one draws none, so this pins
/// the one bit of real logic behind the color pill.
void main() {
  group('colorFromHex', () {
    test('parses a 6-digit hex, with or without the hash', () {
      expect(colorFromHex('#9CA3AF'), const Color(0xFF9CA3AF));
      expect(colorFromHex('9CA3AF'), const Color(0xFF9CA3AF));
    });

    test('keeps an explicit alpha on an 8-digit hex', () {
      expect(colorFromHex('#809CA3AF'), const Color(0x809CA3AF));
    });

    test('returns null for null, empty or malformed input', () {
      expect(colorFromHex(null), isNull);
      expect(colorFromHex(''), isNull);
      expect(colorFromHex('#12'), isNull);
      expect(colorFromHex('#GGGGGG'), isNull);
    });
  });

  group('CartVariantPills', () {
    setUpAll(initCategoriesTestLocalization);

    // The harness loads no translations, so getLocalizedApiText returns the raw
    // localized value for the active (English) locale — the value labels below.
    Map<String, dynamic> optionsOf({String? color}) => <String, dynamic>{
      'color': ?color,
      'attributes': <dynamic>[
        <String, dynamic>{
          'attribute_name': <String, dynamic>{'ar': 'المقاس', 'en': 'Size'},
          'values': <dynamic>[
            <String, dynamic>{
              'name': <String, dynamic>{'ar': 'وسط', 'en': 'Medium'},
            },
          ],
        },
        <String, dynamic>{
          'attribute_name': <String, dynamic>{'ar': 'الخامة', 'en': 'Material'},
          'values': <dynamic>[
            <String, dynamic>{
              'name': <String, dynamic>{'ar': 'بوليستر', 'en': 'Polyester'},
            },
          ],
        },
      ],
    };

    testWidgets('shows a value pill per attribute value', (
      WidgetTester tester,
    ) async {
      await pumpCategoriesWidget(
        tester,
        CartVariantPills(options: optionsOf(color: '#9CA3AF')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Polyester'), findsOneWidget);
    });

    testWidgets('renders nothing when there is no variant', (
      WidgetTester tester,
    ) async {
      await pumpCategoriesWidget(tester, const CartVariantPills(options: null));
      await tester.pumpAndSettle();

      expect(find.byType(Wrap), findsNothing);
    });
  });
}
