import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/wallet/data/datasources/remote/api/wallet_endpoints.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/add_payment_card_vm.dart';

/// The add-card request now sends the raw test-card fields (top level). These
/// lock the exact field names the backend expects — `cvc` (not cvv), a full
/// `expiry_year`, `set_default` in the same request, and no `token`.
void main() {
  test('body carries the raw card fields and the default flag', () {
    final Map<String, dynamic> body = WalletEndpoints.addPaymentCardBody(
      cardholderName: 'Mohamed Yasser',
      cardNumber: '4111111111111111',
      expiryMonth: 12,
      expiryYear: 2035,
      cvc: '123',
      setDefault: true,
    );

    expect(body, <String, dynamic>{
      'cardholder_name': 'Mohamed Yasser',
      'card_number': '4111111111111111',
      'expiry_month': 12,
      'expiry_year': 2035,
      'cvc': '123',
      // Sent with the card, not as a second request after the success toast.
      // A false still leaves a customer's first card default (AddCardAction).
      'set_default': true,
    });
    // token is prohibited by the test-card contract.
    expect(body.containsKey('token'), isFalse);
  });

  group('updatePaymentCardBody (partial)', () {
    test('omits number/cvc when not re-entered, keeps name + expiry', () {
      final Map<String, dynamic> body = WalletEndpoints.updatePaymentCardBody(
        cardholderName: 'Mohamed Yasser',
        expiryMonth: 12,
        expiryYear: 2035,
      );

      expect(body, <String, dynamic>{
        'cardholder_name': 'Mohamed Yasser',
        'expiry_month': 12,
        'expiry_year': 2035,
      });
    });

    test('includes number/cvc when re-entered', () {
      final Map<String, dynamic> body = WalletEndpoints.updatePaymentCardBody(
        cardholderName: 'Mohamed Yasser',
        expiryMonth: 1,
        expiryYear: 2040,
        cardNumber: '4111111111111111',
        cvc: '123',
      );

      expect(body['card_number'], '4111111111111111');
      expect(body['cvc'], '123');
    });

    test('empty number/cvc strings are treated as absent', () {
      final Map<String, dynamic> body = WalletEndpoints.updatePaymentCardBody(
        cardholderName: 'A',
        expiryMonth: 6,
        expiryYear: 2030,
        cardNumber: '',
        cvc: '',
      );

      expect(body.containsKey('card_number'), isFalse);
      expect(body.containsKey('cvc'), isFalse);
    });

    test('set_default is sent only to promote, never as false', () {
      Map<String, dynamic> body(bool setDefault) =>
          WalletEndpoints.updatePaymentCardBody(
            cardholderName: 'A',
            expiryMonth: 6,
            expiryYear: 2030,
            setDefault: setDefault,
          );

      expect(body(true)['set_default'], isTrue);
      // A false on the default card is refused (default_required).
      expect(body(false).containsKey('set_default'), isFalse);
    });
  });

  group('parseExpiry', () {
    test('MM/YY becomes month + full year', () {
      final ({int month, int year}) e =
          AddPaymentCardViewModel.parseExpiry('12/35');
      expect(e.month, 12);
      expect(e.year, 2035);
    });

    test('MMYY without a slash still parses', () {
      final ({int month, int year}) e =
          AddPaymentCardViewModel.parseExpiry('0130');
      expect(e.month, 1);
      expect(e.year, 2030);
    });
  });
}
