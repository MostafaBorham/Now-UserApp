import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/checkout_payment_section.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';

import '../helpers/categories_test_harness.dart';

class _FakeCheckoutViewModel extends CheckoutViewModel {
  int refreshes = 0;

  @override
  void refresh() => refreshes++;
}

class _FakeMyCardsViewModel extends GetMyCardsViewModel {
  void emit(AsyncValue<List<CardPaymentModel>> next) => state = next;
}

/// A card added, edited or deleted in the wallet (reached from checkout through
/// "Top up") shows up in checkout, and each row names its cardholder.
void main() {
  setUpAll(initCategoriesTestLocalization);

  late _FakeCheckoutViewModel checkoutVm;
  late _FakeMyCardsViewModel cardsVm;

  Future<void> pumpSection(WidgetTester tester) async {
    checkoutVm = _FakeCheckoutViewModel();
    cardsVm = _FakeMyCardsViewModel();
    await pumpCategoriesWidget(
      tester,
      const CheckoutPaymentSection(),
      overrides: <Override>[
        checkoutProvider.overrideWith((Ref ref) => checkoutVm),
        getMyCardsProvider.overrideWith((Ref ref) => cardsVm),
        checkoutModelProvider.overrideWith(
          (Ref ref) => const CheckoutModel(
            paymentCards: <CardPaymentModel>[
              CardPaymentModel(
                id: 1,
                cardholderName: 'MOHAMED ALI',
                brand: 'unknown',
                lastFour: '4242',
                maskedNumber: '•••• 4242',
              ),
            ],
          ),
        ),
      ],
    );
  }

  testWidgets('a row shows the cardholder name, never "Unknown"', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester);

    expect(find.text('MOHAMED ALI'), findsOneWidget);
    expect(find.text('•••• 4242'), findsOneWidget);
    expect(find.text('Unknown'), findsNothing);
  });

  testWidgets('checkout prices again once the cards list reloads', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester);

    cardsVm.emit(const AsyncValue<List<CardPaymentModel>>.loading());
    await tester.pump();
    expect(checkoutVm.refreshes, 0);

    cardsVm.emit(const AsyncValue<List<CardPaymentModel>>.data(
      <CardPaymentModel>[],
    ));
    await tester.pump();
    expect(checkoutVm.refreshes, 1);
  });
}
