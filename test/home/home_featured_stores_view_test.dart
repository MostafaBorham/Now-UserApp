import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/glass_product_item_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_featured_stores_view.dart';

import '../helpers/categories_test_harness.dart';

/// Render checks for the `featured_stores` section. Never `pumpAndSettle`
/// these — see the harness note (images and shimmers animate forever).
void main() {
  setUpAll(initCategoriesTestLocalization);

  /// A store shaped like a real feed vendor item, i.e. products carrying
  /// *only* what `/home-sections` sends: no stock, no cart_quantity, no
  /// is_favorite.
  StoreModel feedStore({
    String name = 'Al-Nour Store',
    int id = 3,
    List<ProductModel>? products,
    String? deliveryTime = '15-25',
    double? distance = 2.5,
    double? deliveryFee = 12.0,
  }) => StoreModel(
    id: id,
    name: <String, dynamic>{'en': name, 'ar': name},
    deliveryTime: deliveryTime,
    distance: distance,
    deliveryFee: deliveryFee,
    products: products ??
        <ProductModel>[
          const ProductModel(
            id: 51,
            name: <String, dynamic>{'en': 'Ground Coffee', 'ar': 'Ground Coffee'},
            slug: 'ground-coffee',
            price: 62.0,
            effectivePrice: 42.15,
            discountPercentage: 32.02,
          ),
        ],
  );

  testWidgets('renders the store, its product, and both action buttons',
      (WidgetTester tester) async {
    await pumpCategoriesWidget(
      tester,
      HomeFeaturedStoresView(stores: <StoreModel>[feedStore()]),
    );

    expect(find.text('Al-Nour Store'), findsOneWidget);
    expect(find.text('Ground Coffee'), findsOneWidget);
    // The deal-applied price is the one shown, not the list price.
    expect(find.text('42.15'), findsOneWidget);
    expect(find.text('62.00'), findsNothing);
    // The discount ribbon reads the product's own percentage.
    expect(find.textContaining('32%'), findsOneWidget);
    // Both wired controls are mounted for the product.
    expect(find.byType(AnimatedCartButton), findsOneWidget);
    expect(find.byType(CircularAppFavouriteIcon), findsOneWidget);
  });

  testWidgets('feeds the cart and favourite controls this product\'s ids',
      (WidgetTester tester) async {
    await pumpCategoriesWidget(
      tester,
      HomeFeaturedStoresView(stores: <StoreModel>[feedStore()]),
    );

    // No `product_id` in the feed payload, so both fall back to `id`.
    final AnimatedCartButton cart = tester.widget(
      find.byType(AnimatedCartButton),
    );
    expect(cart.productId, 51);

    final CircularAppFavouriteIcon heart = tester.widget(
      find.byType(CircularAppFavouriteIcon),
    );
    expect(heart.itemId, 51);
    expect(heart.favouriteType, isNotNull); // wired, not the offline fallback
  });

  testWidgets('keeps only the first four products of a store',
      (WidgetTester tester) async {
    await pumpCategoriesWidget(
      tester,
      HomeFeaturedStoresView(
        stores: <StoreModel>[
          feedStore(
            products: List<ProductModel>.generate(
              6,
              (int i) => ProductModel(
                id: i,
                name: <String, dynamic>{'en': 'P$i'},
                price: 1.0,
              ),
            ),
          ),
        ],
      ),
    );

    expect(find.byType(GlassProductItemView), findsNWidgets(4));
  });

  testWidgets('drops stores with no products and renders nothing when none left',
      (WidgetTester tester) async {
    await pumpCategoriesWidget(
      tester,
      HomeFeaturedStoresView(
        stores: <StoreModel>[
          feedStore(name: 'Empty', id: 1, products: const <ProductModel>[]),
        ],
      ),
    );

    expect(find.text('Empty'), findsNothing);
    expect(find.byType(GlassProductItemView), findsNothing);
  });

  testWidgets('survives a store missing its delivery details',
      (WidgetTester tester) async {
    await pumpCategoriesWidget(
      tester,
      HomeFeaturedStoresView(
        stores: <StoreModel>[
          feedStore(deliveryTime: null, distance: null, deliveryFee: null),
        ],
      ),
    );

    expect(find.text('Al-Nour Store'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
