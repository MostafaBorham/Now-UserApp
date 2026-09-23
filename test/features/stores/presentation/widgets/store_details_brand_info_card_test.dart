import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_brand_info_card.dart';

import '../../../../helpers/categories_test_harness.dart';

/// The lead-offer card is the store page's headline price. It used to print the
/// pre-deal price as the price and strike through the nullable compare_price,
/// so an offer read `~~0.00~~ 100.00` while the cart charged 80.00.
void main() {
  setUpAll(initCategoriesTestLocalization);

  /// The add-to-cart label renders as its raw key on the test surface and
  /// overflows the button; only layout overflow is tolerated.
  void ignoreOverflow(WidgetTester tester) {
    for (
      Object? ex = tester.takeException();
      ex != null;
      ex = tester.takeException()
    ) {
      expect(ex.toString(), contains('overflow'));
    }
  }

  testWidgets('a deal product shows the deal price, the base price struck', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      StoreDetailsBrandInfoCard(
        product: sampleProduct().copyWith(price: 100, discountPrice: 80),
      ),
    );
    ignoreOverflow(tester);

    expect(find.textContaining('80.00'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(OldPriceWidget),
        matching: find.textContaining('100.00'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('0.00 '), findsNothing);
  });

  testWidgets('no deal: the price alone, nothing struck through', (
    WidgetTester tester,
  ) async {
    final ProductModel product = sampleProduct().copyWith(
      price: 100,
      discountPrice: 100,
    );
    await pumpCategoriesWidget(
      tester,
      StoreDetailsBrandInfoCard(product: product),
    );
    ignoreOverflow(tester);

    expect(find.textContaining('100.00'), findsOneWidget);
    expect(find.byType(OldPriceWidget), findsNothing);
  });
}
