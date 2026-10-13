import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';

/// The checkout preview now carries the customer's saved cards under
/// `checkout.payment_cards`. These cover parsing them and resolving the default
/// card that a card-payment defaults to.
void main() {
  Map<String, dynamic> previewWithCards(List<Map<String, dynamic>> cards) => {
        'checkout': {
          'vendor_groups': <dynamic>[],
          'summary': <String, dynamic>{},
          'payment_cards': cards,
        },
      };

  test('cart preview parses payment_cards', () {
    final CheckoutModel model = CheckoutModel.fromJson(
      previewWithCards([
        {'id': 1, 'brand': 'visa', 'last_four': '4242', 'is_default': false},
        {'id': 2, 'brand': 'mastercard', 'last_four': '5555', 'is_default': true},
      ]),
    );

    expect(model.paymentCards.map((CardPaymentModel c) => c.id), [1, 2]);
    expect(model.paymentCards[1].brand, 'mastercard');
  });

  test('single-store preview parses payment_cards', () {
    final CheckoutModel model = CheckoutModel.fromSingleStoreJson({
      'checkout': {
        'products': <dynamic>[],
        'summary': <String, dynamic>{},
        'payment_cards': [
          {'id': 9, 'brand': 'visa', 'last_four': '1111'},
        ],
      },
    });

    expect(model.paymentCards.single.id, 9);
  });

  test('missing payment_cards yields an empty list', () {
    final CheckoutModel model = CheckoutModel.fromJson({
      'checkout': {'vendor_groups': <dynamic>[], 'summary': <String, dynamic>{}},
    });

    expect(model.paymentCards, isEmpty);
  });

  group('resolveDefaultCard', () {
    test('prefers the server-marked default over position', () {
      final CheckoutModel model = CheckoutModel.fromJson(
        previewWithCards([
          {'id': 1, 'is_default': false},
          {'id': 2, 'is_default': true},
        ]),
      );

      expect(CheckoutModel.resolveDefaultCard(model.paymentCards)?.id, 2);
    });

    test('falls back to the first card when none is marked default', () {
      const List<CardPaymentModel> cards = [
        CardPaymentModel(id: 7),
        CardPaymentModel(id: 8),
      ];

      expect(CheckoutModel.resolveDefaultCard(cards)?.id, 7);
    });

    test('is null for an empty list', () {
      expect(CheckoutModel.resolveDefaultCard(const []), isNull);
    });
  });

  group('payingCard', () {
    const List<CardPaymentModel> cards = [
      CardPaymentModel(id: 1),
      CardPaymentModel(id: 2, isDefault: true),
    ];

    test('is the picked card while it is still listed', () {
      expect(CheckoutModel.payingCard(cards, 1)?.id, 1);
    });

    test('falls back to the default when nothing is picked', () {
      expect(CheckoutModel.payingCard(cards, null)?.id, 2);
    });

    test('falls back to the default when the pick was deleted', () {
      expect(CheckoutModel.payingCard(cards, 99)?.id, 2);
    });
  });

  test('displayCardBrand hides the test vault\'s "unknown"', () {
    expect(displayCardBrand('visa'), 'Visa');
    expect(displayCardBrand('unknown'), isNull);
    expect(displayCardBrand(''), isNull);
    expect(displayCardBrand(null), isNull);
  });
}
