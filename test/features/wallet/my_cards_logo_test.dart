import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/my_cards_view.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';

import '../../helpers/categories_test_harness.dart';

class _FakeMyCardsViewModel extends GetMyCardsViewModel {
  _FakeMyCardsViewModel(List<CardPaymentModel> cards) {
    state = AsyncValue<List<CardPaymentModel>>.data(cards);
  }
}

/// Each saved card carries its own brand's logo; a brand the app has no logo
/// for gets a plain card icon, never another brand's.
void main() {
  setUpAll(initCategoriesTestLocalization);

  Finder logo(String file) => find.byWidgetPredicate(
    (Widget w) =>
        w is SvgPicture &&
        (w.bytesLoader as SvgAssetLoader).assetName.endsWith(file),
  );

  testWidgets('visa and mastercard keep their logos; unknown gets an icon', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      const MyCardsView(),
      overrides: <Override>[
        getMyCardsProvider.overrideWith(
          (Ref ref) => _FakeMyCardsViewModel(const <CardPaymentModel>[
            CardPaymentModel(id: 1, brand: 'visa', lastFour: '4242'),
            CardPaymentModel(id: 2, brand: 'mastercard', lastFour: '4444'),
            CardPaymentModel(id: 3, brand: 'unknown', lastFour: '0000'),
          ]),
        ),
      ],
    );

    expect(logo('visa-logo.svg'), findsOneWidget);
    expect(logo('master-logo.svg'), findsOneWidget);
    expect(find.byIcon(Icons.credit_card), findsOneWidget);
  });
}
