import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/checkout_payment_section.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';

import '../helpers/categories_test_harness.dart';

class _FakeCheckoutViewModel extends CheckoutViewModel {
  void emit(AsyncValue<CheckoutModel?> next) => state = next;
}

class _FakeMyCardsViewModel extends GetMyCardsViewModel {
  void emit(AsyncValue<List<CardPaymentModel>> next) => state = next;
}

const CardPaymentModel _saved = CardPaymentModel(
  id: 1,
  cardholderName: 'MOHAMED ALI',
  brand: 'unknown',
  lastFour: '4242',
  maskedNumber: '•••• 4242',
);

const CardPaymentModel _added = CardPaymentModel(
  id: 2,
  cardholderName: 'SARA ALI',
  lastFour: '1111',
);

/// Checkout lists the wallet's cards, so one added, edited or deleted from
/// checkout shows up even when the preview can't be re-priced; each row names
/// its cardholder.
void main() {
  setUpAll(initCategoriesTestLocalization);

  late _FakeCheckoutViewModel checkoutVm;
  late _FakeMyCardsViewModel cardsVm;

  // The wallet's list starts loading (as during a reload); the preview, loaded,
  // holds [_saved].
  Future<void> pumpSection(WidgetTester tester) async {
    checkoutVm = _FakeCheckoutViewModel()
      ..emit(
        const AsyncValue<CheckoutModel?>.data(
          CheckoutModel(paymentCards: <CardPaymentModel>[_saved]),
        ),
      );
    cardsVm = _FakeMyCardsViewModel();
    await pumpCategoriesWidget(
      tester,
      const CheckoutPaymentSection(),
      overrides: <Override>[
        checkoutProvider.overrideWith((Ref ref) => checkoutVm),
        getMyCardsProvider.overrideWith((Ref ref) => cardsVm),
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

  testWidgets('a card added while the preview is refused still shows', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester);

    // The store closed: the re-price fails and keeps the old preview.
    checkoutVm.emit(
      const AsyncValue<CheckoutModel?>.error(
        'not accepting orders',
        StackTrace.empty,
      ).copyWithPrevious(checkoutVm.state),
    );
    cardsVm.emit(
      const AsyncValue<List<CardPaymentModel>>.data(<CardPaymentModel>[
        _saved,
        _added,
      ]),
    );
    await tester.pump();

    expect(find.text('SARA ALI'), findsOneWidget);
    expect(find.text('MOHAMED ALI'), findsOneWidget);
  });

  testWidgets('an expired wallet card is not offered', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester);

    cardsVm.emit(
      const AsyncValue<List<CardPaymentModel>>.data(<CardPaymentModel>[
        _saved,
        CardPaymentModel(id: 3, cardholderName: 'OLD CARD', isExpired: true),
      ]),
    );
    await tester.pump();

    expect(find.text('MOHAMED ALI'), findsOneWidget);
    expect(find.text('OLD CARD'), findsNothing);
  });
}
