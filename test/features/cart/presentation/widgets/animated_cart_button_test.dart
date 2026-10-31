import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_button.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/update_cart_product_vm.dart';

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

  // The card's first add sent 1 whatever the product's minimum, which the
  // server refuses; the product page already started at the minimum.
  testWidgets('first add sends the minimum order quantity', (tester) async {
    final List<int> sent = <int>[];
    await pumpCategoriesScreen(
      tester,
      const Scaffold(
        body: Center(
          child: AnimatedCartButton(
            productId: 7,
            stock: 10,
            minOrderQuantity: 3,
          ),
        ),
      ),
      overrides: <Override>[
        getCartProvider.overrideWith(
          (Ref ref) =>
              GetCartViewModel(const AsyncValue<CartModel>.data(CartModel())),
        ),
        updateCartProductProvider.overrideWith(
          (Ref ref, int laneId) => _RecordingCartVm(ref, laneId, sent),
        ),
      ],
    );

    await tester.tap(find.byType(AnimatedCartButton));
    await tester.pumpAndSettle();

    expect(sent, <int>[3]);
  });
}

class _RecordingCartVm extends UpdateCartProductViewModel {
  _RecordingCartVm(super.ref, super.laneId, this.sent);

  final List<int> sent;

  @override
  Future<void> updateCartProductQuantity(
    int productQuantity, {
    required int productId,
    int? cartItemId,
    int? seededQuantity,
  }) async => sent.add(productQuantity);
}
