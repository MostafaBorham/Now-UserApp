import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/add_card_view.dart';

import '../../helpers/categories_test_harness.dart';

/// Editing a card can make it the default, but the current default stays
/// locked on: the server refuses to leave the customer with no default.
void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('edit mode locks the default checkbox on the default card', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      AddCardView(card: CardPaymentModel(id: 1, isDefault: true)),
    );

    final Checkbox box = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(box.value, isTrue);
    expect(box.onChanged, isNull);
  });

  testWidgets('edit mode lets a non-default card be made the default', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      AddCardView(card: CardPaymentModel(id: 1, isDefault: false)),
    );

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });

  testWidgets('add mode leaves the default checkbox editable', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(tester, const AddCardView());

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNotNull);
  });

  testWidgets('the add button stays disabled until every field is valid', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(tester, const AddCardView());
    bool disabled() => tester
        .widget<PrimaryAppButton>(find.byType(PrimaryAppButton))
        .isDisabled;
    final Finder fields = find.byType(TextFormField);

    expect(disabled(), isTrue);

    await tester.enterText(fields.at(0), 'Jane Doe');
    await tester.enterText(fields.at(1), '4242424242424242');
    await tester.enterText(fields.at(2), '1240');
    await tester.pump();
    expect(disabled(), isTrue, reason: 'CVV still empty');

    await tester.enterText(fields.at(3), '123');
    await tester.pump();
    expect(disabled(), isFalse);

    await tester.enterText(fields.at(1), '4242424242424241'); // fails Luhn
    await tester.pump();
    expect(disabled(), isTrue);
  });
}
