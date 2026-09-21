import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/add_card_form.dart';

import '../../helpers/categories_test_harness.dart';

/// Validation on the shared add-card form. The test harness loads empty
/// translations, so `.tr()` returns the raw LangKeys key — which is exactly what
/// these error messages assert against.
void main() {
  setUpAll(initCategoriesTestLocalization);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController name;
  late TextEditingController number;
  late TextEditingController expiry;
  late TextEditingController cvv;

  setUp(() {
    name = TextEditingController();
    number = TextEditingController();
    expiry = TextEditingController();
    cvv = TextEditingController();
  });

  tearDown(() {
    name.dispose();
    number.dispose();
    expiry.dispose();
    cvv.dispose();
  });

  Future<void> pumpForm(WidgetTester tester) => pumpCategoriesWidget(
        tester,
        Form(
          key: formKey,
          child: AddCardForm(
            nameController: name,
            numberController: number,
            expiryController: expiry,
            cvvController: cvv,
          ),
        ),
      );

  testWidgets('blank fields fail with the required message', (tester) async {
    await pumpForm(tester);

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    // Every field is empty, so at least one "required" error is shown.
    expect(find.text('requiredField'), findsWidgets);
  });

  testWidgets('a valid card passes every field', (tester) async {
    await pumpForm(tester);
    // 4242… is a Luhn-valid test PAN; expiry is a far-future month.
    name.text = 'Jane Doe';
    number.text = '4242424242424242';
    expiry.text = '12/40';
    cvv.text = '123';

    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('a Luhn-invalid number is rejected', (tester) async {
    await pumpForm(tester);
    name.text = 'Jane Doe';
    number.text = '4242424242424241'; // last digit breaks the checksum
    expiry.text = '12/40';
    cvv.text = '123';

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('invalidCardNumber'), findsOneWidget);
  });

  testWidgets('a past expiry is rejected as expired', (tester) async {
    await pumpForm(tester);
    name.text = 'Jane Doe';
    number.text = '4242424242424242';
    expiry.text = '01/20';
    cvv.text = '123';

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('cardExpired'), findsOneWidget);
  });

  testWidgets('an impossible month is an invalid expiry', (tester) async {
    await pumpForm(tester);
    name.text = 'Jane Doe';
    number.text = '4242424242424242';
    expiry.text = '13/40';
    cvv.text = '123';

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('invalidExpiryDate'), findsOneWidget);
  });

  testWidgets('a too-short CVV is rejected', (tester) async {
    await pumpForm(tester);
    name.text = 'Jane Doe';
    number.text = '4242424242424242';
    expiry.text = '12/40';
    cvv.text = '12';

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('invalidCvv'), findsOneWidget);
  });

  testWidgets('the expiry field auto-formats to MM/YY', (tester) async {
    await pumpForm(tester);
    await tester.enterText(find.byType(TextFormField).at(2), '1240');
    expect(expiry.text, '12/40');
  });
}
