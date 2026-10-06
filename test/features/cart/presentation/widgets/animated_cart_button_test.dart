import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_button.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';

import '../../../../helpers/categories_test_harness.dart';

/// BUG-022 (QA V2): a product in the cart as two variant lines showed one
/// line's count, and its +/- went out without a line id (a 422).
void main() {
  setUpAll(initCategoriesTestLocalization);

  Future<void> pump(WidgetTester tester, List<ProductModel> lines) async {
    await pumpCategoriesScreen(
      tester,
      const Scaffold(
        body: Center(
          child: AnimatedCartButton(productId: 7, productSlug: 'shirt'),
        ),
      ),
      overrides: <Override>[
        getCartProvider.overrideWith(
          (Ref ref) => GetCartViewModel(
            AsyncValue<CartModel>.data(
              CartModel(
                vendors: <CartVendorModel>[CartVendorModel(products: lines)],
              ),
            ),
          ),
        ),
      ],
      destinationRoutes: <RouteBase>[
        GoRoute(
          name: AppRoutes.productDetailsScreen,
          path: '/${AppRoutes.productDetailsScreen}',
          builder: (context, state) => Text('product ${state.extra}'),
        ),
      ],
    );
  }

  testWidgets('two variant lines: shows the total, a tap opens the product', (
    tester,
  ) async {
    await pump(tester, const <ProductModel>[
      ProductModel(productId: 7, cartItemId: 1, quantity: 2),
      ProductModel(productId: 7, cartItemId: 2, quantity: 3),
    ]);

    expect(find.text('5'), findsOneWidget);

    await tester.tap(find.byType(AnimatedCartButton));
    await tester.pumpAndSettle();

    expect(find.text('product shirt'), findsOneWidget);
  });

  testWidgets('one line: a tap opens the counter in place', (tester) async {
    await pump(tester, const <ProductModel>[
      ProductModel(productId: 7, cartItemId: 1, quantity: 2),
    ]);

    await tester.tap(find.byType(AnimatedCartButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('product'), findsNothing);
    // Let the counter's idle collapse timer run out.
    await tester.pump(const Duration(seconds: 3));
  });
}
