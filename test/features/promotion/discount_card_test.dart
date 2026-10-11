import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/features/promotion/presentation/widgets/discount_code/discount_card.dart';

import '../../helpers/categories_test_harness.dart';

// BUG-042: only the code pill copied; a tap anywhere else on the coupon did
// nothing.
void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('a tap anywhere on the coupon copies it', (
    WidgetTester tester,
  ) async {
    int copies = 0;
    await pumpCategoriesWidget(
      tester,
      // The test font draws every glyph 1 em wide and the labels are bare
      // keys, so at full size the text column overflows the ticket.
      Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(0.5)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DiscountCard(
              coupon: const CouponModel(code: 'SAVE10', discountValue: 10),
              onCopy: () => copies++,
            ),
          ),
        ),
      ),
    );

    // The value panel, far from the pill.
    await tester.tapAt(
      tester.getTopLeft(find.byType(DiscountCard)) + const Offset(30, 30),
    );
    expect(copies, 1);
  });
}
