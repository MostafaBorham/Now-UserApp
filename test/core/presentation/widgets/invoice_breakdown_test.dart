import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/invoice_breakdown.dart';

import '../../../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('free delivery, red deductions and their sum as savings', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      const InvoiceBreakdown(
        subtotal: 100,
        tax: 13.5,
        deliveryFee: 0,
        total: 98.8,
        discounts: <(String, double)>[('Coupon', 10.1), ('Voucher', 4.6)],
      ),
    );

    expect(find.text(LangKeys.freeKey), findsOneWidget);
    expect(find.text('−'), findsNWidgets(2));
    expect(find.text('14.70'), findsOneWidget);
    expect(find.text(LangKeys.totalSavingsKey), findsOneWidget);
    expect(find.text(LangKeys.allPricesIncludeVatKey), findsOneWidget);
    expect(find.text(LangKeys.driverTipKey), findsNothing);
  });

  testWidgets('a paid delivery shows its fee; no discount, no savings strip', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      const InvoiceBreakdown(
        subtotal: 100,
        tax: 15,
        deliveryFee: 12,
        total: 132,
        driverTip: 5,
        discounts: <(String, double)>[('Coupon', 0)],
      ),
    );

    expect(find.text(LangKeys.freeKey), findsNothing);
    expect(find.text('12.00'), findsOneWidget);
    expect(find.text(LangKeys.driverTipKey), findsOneWidget);
    expect(find.text('Coupon'), findsNothing);
    expect(find.text(LangKeys.totalSavingsKey), findsNothing);
  });
}
