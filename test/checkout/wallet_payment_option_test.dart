import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/payment_method/wallet_payment_option.dart';

import '../helpers/categories_test_harness.dart';

/// Guards the wallet toggle: ticked on arrival (so the wallet is the default
/// payment method), and the shortfall note follows it.
void main() {
  setUpAll(initCategoriesTestLocalization);

  // No translations are loaded in the harness, so `.tr()` yields the key.
  Finder note() => find.text(LangKeys.walletShortfallHintKey);

  testWidgets('starts ticked, and the note tracks the tick', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(tester, const WalletPaymentOption());

    expect(note(), findsOneWidget);

    await tester.tap(find.text(LangKeys.walletKey));
    await tester.pump();

    expect(note(), findsNothing);
  });

  testWidgets('the note is never truncated', (WidgetTester tester) async {
    await pumpCategoriesWidget(tester, const WalletPaymentOption());

    // Every `AppTextStyles` entry bakes in `TextOverflow.ellipsis`, and an
    // ellipsis with no `maxLines` collapses the paragraph to a single line —
    // so the note must opt back out or it loses everything past line one.
    final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
      note(),
    );
    expect(paragraph.overflow, TextOverflow.visible);
  });
}
