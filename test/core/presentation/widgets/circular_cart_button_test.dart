import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cart/cart_badge.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cart/circular_cart_button.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';

import '../../../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  Override cartWith(CartModel cart) => getCartProvider.overrideWith(
    (Ref ref) => GetCartViewModel(AsyncValue<CartModel>.data(cart)),
  );

  testWidgets('badges the app-bar cart with the units in the cart', (
    WidgetTester tester,
  ) async {
    await pumpCategoriesWidget(
      tester,
      const CircularCartButton(),
      overrides: [
        cartWith(
          const CartModel(
            vendors: <CartVendorModel>[
              CartVendorModel(
                products: <ProductModel>[
                  ProductModel(quantity: 2),
                  ProductModel(quantity: 3),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('an empty cart shows no badge', (WidgetTester tester) async {
    await pumpCategoriesWidget(
      tester,
      const CircularCartButton(),
      overrides: [cartWith(const CartModel())],
    );

    expect(find.byType(CartBadge), findsNothing);
  });
}
