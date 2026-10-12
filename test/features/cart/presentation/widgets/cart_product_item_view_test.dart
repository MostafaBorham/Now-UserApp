import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/dialogs/app_custom_alert_dialog.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/cart_product_item_view.dart';

import '../../../../helpers/categories_test_harness.dart';

/// A line is removed by its own delete button, which asks first. The − used to
/// turn into that delete at the store's minimum; it now just goes inert there.
void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('delete asks first; − at the minimum does nothing', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pumpCategoriesWidget(
      tester,
      CartProductItemView(
        product: ProductModel(
          productId: 10,
          cartItemId: 100,
          quantity: 1,
          images: const <String>[],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final InkWell minus = tester.widget<InkWell>(
      find.ancestor(
        of: find.byIcon(Icons.remove_rounded),
        matching: find.byType(InkWell),
      ),
    );
    expect(minus.onTap, isNull);

    // The harness loads no translations, so the label reads as its key.
    await tester.tap(find.bySemanticsLabel(LangKeys.removeProductKey.tr()));
    await tester.pumpAndSettle();
    expect(find.byType(AppCustomAlertDialog), findsOneWidget);

    semantics.dispose();
  });
}
