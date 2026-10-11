import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/widgets/checkout/confirm_order_button.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_discount_vm.dart';

import '../helpers/categories_test_harness.dart';

// BUG-039: a tap on Confirm while a coupon or voucher was still applying placed
// the order without it.
void main() {
  setUpAll(initCategoriesTestLocalization);

  Future<int> tapsWhileApplying(WidgetTester tester, int applying) async {
    int taps = 0;
    await pumpCategoriesWidget(
      tester,
      ConfirmOrderButton(onConfirm: () => taps++),
      overrides: <Override>[
        discountApplyingProvider.overrideWith((Ref ref) => applying),
      ],
    );
    await tester.tap(find.byType(ConfirmOrderButton), warnIfMissed: false);
    return taps;
  }

  testWidgets('blocked while a discount applies', (WidgetTester tester) async {
    expect(await tapsWhileApplying(tester, 1), 0);
  });

  testWidgets('tappable once nothing applies', (WidgetTester tester) async {
    expect(await tapsWhileApplying(tester, 0), 1);
  });
}
