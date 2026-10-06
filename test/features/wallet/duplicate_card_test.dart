import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/add_payment_card_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';

import '../../helpers/categories_test_harness.dart';

class _LoadedCards extends GetMyCardsViewModel {
  _LoadedCards(List<CardPaymentModel> cards) {
    state = AsyncValue<List<CardPaymentModel>>.data(cards);
  }
}

/// BUG-014 (QA V2): the same card could be saved twice. A card matching a
/// loaded one on last four + expiry is refused before any request goes out.
void main() {
  setUpAll(initCategoriesTestLocalization);

  const CardPaymentModel saved = CardPaymentModel(
    id: 5,
    lastFour: '4242',
    expiryMonth: 12,
    expiryYear: 2040,
  );

  late ProviderContainer container;
  setUp(() {
    container = ProviderContainer(
      overrides: <Override>[
        getMyCardsProvider.overrideWith(
          (Ref ref) => _LoadedCards(const <CardPaymentModel>[saved]),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  AddPaymentCardViewModel vm() =>
      container.read(addPaymentCardProvider.notifier);

  test('adding a saved card again is refused', () async {
    final String? error = await vm().addPaymentCard(
      cardholderName: 'Jane Doe',
      cardNumber: '4242 4242 4242 4242',
      expiry: '12/40',
      cvc: '123',
    );

    expect(error, LangKeys.cardAlreadySavedKey);
  });

  group('isAlreadySaved', () {
    bool check(String number, int month, int year, {int? except}) =>
        AddPaymentCardViewModel.isAlreadySaved(
          const <CardPaymentModel>[saved],
          number,
          (month: month, year: year),
          except: except,
        );

    test('same last four and expiry is a duplicate', () {
      expect(check('4242424242424242', 12, 2040), isTrue);
    });

    test('another expiry or last four is a different card', () {
      expect(check('4242424242424242', 11, 2040), isFalse);
      expect(check('4000056655665556', 12, 2040), isFalse);
    });

    test('the card being edited is not its own duplicate', () {
      expect(check('4242424242424242', 12, 2040, except: 5), isFalse);
    });

    test('a two-digit expiry year from the server still matches', () {
      expect(
        AddPaymentCardViewModel.isAlreadySaved(
          const <CardPaymentModel>[
            CardPaymentModel(
              id: 6,
              lastFour: '4242',
              expiryMonth: 12,
              expiryYear: 40,
            ),
          ],
          '4242424242424242',
          (month: 12, year: 2040),
        ),
        isTrue,
      );
    });
  });
}
