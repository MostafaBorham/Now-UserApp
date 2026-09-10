import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_button.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_never_miss_offers_item.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_never_miss_offers_section.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_view_all_widget.dart';
import 'package:nowdelivery_user_app/features/products/data/models/rating_model.dart';

import '../helpers/categories_test_harness.dart';

/// Render checks for the `flash_offers` section — chiefly that each card's two
/// actions (favourite, cart) are wired to the real product rather than left on
/// their local-only fallbacks. Never `pumpAndSettle` these: the strip
/// auto-scrolls forever (see the harness note).
void main() {
  setUpAll(initCategoriesTestLocalization);

  /// A product shaped like a `flash_offers` item: deal-applied price, a flat
  /// vendor logo, no `product_id` and no `stock`.
  ProductModel offerProduct({
    int? id = 52,
    String name = 'Computer',
    double? effectivePrice = 13.6,
    double? discountPercentage = 32.0,
    bool? isFavorite = true,
  }) => ProductModel(
    id: id,
    slug: 'computer',
    name: <String, dynamic>{'en': name, 'ar': name},
    price: 20.0,
    effectivePrice: effectivePrice,
    discountPercentage: discountPercentage,
    images: const <String>['http://x/p52.png'],
    rating: const RatingModel(average: 4.5, total: 2),
    vendor: const StoreModel(logoUrl: 'http://x/vendor.png'),
    isFavorite: isFavorite,
  );

  /// The section needs a bounded height (its strip sits in an `Expanded`), the
  /// same way `HomeView` wraps it in an `AspectRatio`.
  Future<void> pumpSection(
    WidgetTester tester,
    List<ProductModel> products, {
    Color? backgroundColor,
    Color? viewAllTextColor,
    Color? viewAllUnderlineColor,
  }) => pumpCategoriesWidget(
    tester,
    AspectRatio(
      aspectRatio: 1,
      child: HomeNeverMissOffersSection(
        products: products,
        backgroundColor: backgroundColor,
        viewAllTextColor: viewAllTextColor,
        viewAllUnderlineColor: viewAllUnderlineColor,
      ),
    ),
  );

  /// The section's background wash — the first gradient in its subtree (the
  /// backdrop sits above the cards, which carry gradients of their own).
  LinearGradient backdropGradient(WidgetTester tester) {
    final Container container = tester.firstWidget<Container>(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).gradient is LinearGradient,
      ),
    );
    return (container.decoration! as BoxDecoration).gradient! as LinearGradient;
  }

  HomeViewAllWidget viewAllChip(WidgetTester tester) =>
      tester.widget<HomeViewAllWidget>(find.byType(HomeViewAllWidget));

  testWidgets('renders the name, deal price and struck list price', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester, <ProductModel>[offerProduct()]);

    expect(find.text('Computer'), findsWidgets);
    // The price charged is the deal-applied one, with the list price beside it.
    expect(find.text('13.60'), findsWidgets);
    expect(find.text('20.00'), findsWidgets);
    expect(find.text('32%'), findsWidgets);
  });

  testWidgets('wires the favourite heart to this product', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester, <ProductModel>[offerProduct()]);

    final CircularAppFavouriteIcon heart = tester.widget(
      find.byType(CircularAppFavouriteIcon).first,
    );
    // Integrated, not the local-flip fallback: a tap hits the favourites API.
    expect(heart.favouriteType, FavouriteType.product);
    expect(heart.itemId, 52);
    // Seeded from the feed, so an already-favourited product opens filled and
    // its first tap removes rather than re-adds.
    expect(heart.isFavourite, isTrue);
  });

  testWidgets('wires the cart button to this product', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester, <ProductModel>[offerProduct()]);

    final AnimatedCartButton cart = tester.widget(
      find.byType(AnimatedCartButton).first,
    );
    // The feed sends no `product_id`, so the control falls back to `id`; a null
    // here would silently leave it counting locally instead of calling the API.
    expect(cart.productId, 52);
    expect(cart.productQuantity, 0);
  });

  testWidgets('drops the discount badge and old price without a discount', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester, <ProductModel>[
      offerProduct(effectivePrice: null, discountPercentage: null),
    ]);

    // Nothing rendered as a "0%" badge or a struck price equal to the real one.
    expect(find.text('0%'), findsNothing);
    expect(find.text('20.00'), findsWidgets); // the price, once
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders one card per product', (WidgetTester tester) async {
    await pumpSection(tester, <ProductModel>[
      offerProduct(id: 1, name: 'First'),
      offerProduct(id: 2, name: 'Second'),
    ]);

    // The strip repeats its cycle, so both names are on screen at least once.
    expect(find.text('First'), findsWidgets);
    expect(find.text('Second'), findsWidgets);
    expect(find.byType(HomeNeverMissOffersItem), findsWidgets);
  });

  testWidgets('paints the background and See All chip the feed asked for', (
    WidgetTester tester,
  ) async {
    await pumpSection(
      tester,
      <ProductModel>[offerProduct()],
      backgroundColor: const Color(0xFFC800FF),
      viewAllTextColor: const Color(0xFFFFFFFF),
      viewAllUnderlineColor: const Color(0xFF475569),
    );

    // The wash keeps the design's fade to white; only its top colour is the
    // admin's.
    expect(
      backdropGradient(tester).colors.first,
      const Color(0xFFC800FF).withValues(alpha: 0.9),
    );

    final HomeViewAllWidget chip = viewAllChip(tester);
    expect(chip.textColor, const Color(0xFFFFFFFF));
    expect(chip.startBackgroundColor, const Color(0xFF475569));
  });

  testWidgets('falls back to the theme colours when the feed sends none', (
    WidgetTester tester,
  ) async {
    // An uncoloured section has to look like the shipped design, not render
    // a transparent wash or a chip with no label colour.
    await pumpSection(tester, <ProductModel>[offerProduct()]);

    expect(backdropGradient(tester).colors.first.a, 0.9);
    expect(viewAllChip(tester).textColor, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
