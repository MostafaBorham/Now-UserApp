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

  Future<bool> numberIsValid(WidgetTester tester, String value) async {
    name.text = 'Jane Doe';
    number.text = value;
    expiry.text = '12/40';
    cvv.text = '123';
    return formKey.currentState!.validate();
  }

  testWidgets('accepts every real-world card length and network', (
    tester,
  ) async {
    await pumpForm(tester);
    const Map<String, String> cards = <String, String>{
      'Maestro 12': '500000000009',
      'Visa 13': '4222222222222',
      'Diners 14': '36227206271667',
      'Amex 15': '378282246310005',
      'Mastercard 16': '5555555555554444',
      'Visa 16': '4242424242424242',
      'Meeza 16': '5078030000000003',
      'Discover 16': '6011111111111117',
      'JCB 16': '3566002020360505',
      'UnionPay 16 non-Luhn': '6200000000000047',
      'UnionPay 19': '6205500000000000004',
      'Visa 19': '4000000000000000006',
    };
    for (final MapEntry<String, String> card in cards.entries) {
      expect(await numberIsValid(tester, card.value), isTrue, reason: card.key);
    }
  });

  testWidgets('rejects numbers shorter than 12 digits', (tester) async {
    await pumpForm(tester);
    expect(await numberIsValid(tester, '42424242426'), isFalse);
    await tester.pump();
    expect(find.text('invalidCardNumber'), findsOneWidget);
  });

  testWidgets('the number field caps at 19 digits, grouped in fours', (
    tester,
  ) async {
    await pumpForm(tester);
    await tester.enterText(
      find.byType(TextFormField).at(1),
      '4000-0000 0000 0000 0061 23',
    );
    expect(number.text, '4000 0000 0000 0000 006');
  });

  testWidgets('a grouped number still validates', (tester) async {
    await pumpForm(tester);
    expect(await numberIsValid(tester, '4242 4242 4242 4242'), isTrue);
  });

  group('CardNumberInputFormatter', () {
    final CardNumberInputFormatter formatter = CardNumberInputFormatter();

    TextEditingValue edit(String oldText, String newText, int caret) =>
        formatter.formatEditUpdate(
          TextEditingValue(
            text: oldText,
            selection: TextSelection.collapsed(offset: oldText.length),
          ),
          TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: caret),
          ),
        );

    test('typing the fifth digit opens a new group', () {
      final TextEditingValue v = edit('4242', '42424', 5);
      expect(v.text, '4242 4');
      expect(v.selection.baseOffset, 6);
    });

    test('no trailing space after a full group', () {
      expect(edit('424', '4242', 4).text, '4242');
    });

    test('backspace on a group space deletes the digit before it', () {
      // '4242 4|' → caret after the space, backspace removes the space.
      final TextEditingValue v = edit('4242 4', '42424', 4);
      expect(v.text, '4244');
      expect(v.selection.baseOffset, 3);
    });

    test('a mid-number insert keeps the caret after the typed digit', () {
      // '4242 |4242' + '1' → '4242 14242' → '4242 1424 2', caret after the 1.
      final TextEditingValue v = edit('4242 4242', '4242 14242', 6);
      expect(v.text, '4242 1424 2');
      expect(v.selection.baseOffset, 6);
    });
  });

  testWidgets('the name field keeps English letters and spaces only', (
    tester,
  ) async {
    await pumpForm(tester);
    await tester.enterText(
      find.byType(TextFormField).first,
      'José ياسر Ya55er_@Ahmed!',
    );
    expect(name.text, 'Jos  YaerAhmed');
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
