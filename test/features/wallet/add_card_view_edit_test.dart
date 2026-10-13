import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/add_card_view.dart';

import '../../helpers/categories_test_harness.dart';

/// Editing a card shows its default flag but can't change it either way: the
/// default is changed from the cards list.
void main() {
  setUpAll(initCategoriesTestLocalization);

  for (final bool isDefault in <bool>[true, false]) {
    testWidgets('edit mode locks the default checkbox (isDefault: $isDefault)', (
      WidgetTester tester,
    ) async {
      await pumpCategoriesWidget(
        tester,
        AddCardView(card: CardPaymentModel(id: 1, isDefault: isDefault)),
      );

      final Checkbox box = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(box.value, isDefault);
      expect(box.onChanged, isNull);
    });
  }

  testWidgets('add mode leaves the default checkbox editable', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(tester, const AddCardView());

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNotNull);
  });
}
