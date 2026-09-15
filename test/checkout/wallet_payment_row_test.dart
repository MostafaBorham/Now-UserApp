import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/wallet_payment_row.dart';

import '../helpers/categories_test_harness.dart';



void main() {
  setUpAll(initCategoriesTestLocalization);


  Finder note() => find.text(LangKeys.walletShortfallHintKey);

  testWidgets('starts ticked, and the note tracks the tick', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(tester, const WalletPaymentRow());

    expect(note(), findsOneWidget);

    await tester.tap(find.text(LangKeys.walletKey));
    await tester.pump();

    expect(note(), findsNothing);
  });

  testWidgets('the note is never truncated', (WidgetTester tester) async {
    await pumpCategoriesWidget(tester, const WalletPaymentRow());




    final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
      note(),
    );
    expect(paragraph.overflow, TextOverflow.visible);
  });
}
