import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_button.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_never_miss_offers_item.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_never_miss_offers_section.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_view_all_widget.dart';
import 'package:nowdelivery_user_app/features/products/data/models/rating_model.dart';

import '../helpers/categories_test_harness.dart';





void main() {
  setUpAll(initCategoriesTestLocalization);



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

    expect(find.text('13.60'), findsWidgets);
    expect(find.text('20.00'), findsWidgets);
    expect(find.text('32%'), findsWidgets);
  });

  testWidgets('a compare-price markdown strikes the compare price', (
    WidgetTester tester,
  ) async {
    // No deal: the home payload's discount is the compare-price markdown and
    // the price charged is the list price. Striking `price` read
    // "20.00 ~~20.00~~" here.
    await pumpSection(tester, <ProductModel>[
      offerProduct(effectivePrice: 20.0, discountPercentage: 20.0).copyWith(
        comparePrice: 25.0,
      ),
    ]);

    expect(
      find.descendant(
        of: find.byType(OldPriceWidget),
        matching: find.text('25.00'),
      ),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: find.byType(OldPriceWidget),
        matching: find.text('20.00'),
      ),
      findsNothing,
    );
  });

  testWidgets('wires the favourite heart to this product', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester, <ProductModel>[offerProduct()]);

    final CircularAppFavouriteIcon heart = tester.widget(
      find.byType(CircularAppFavouriteIcon).first,
    );

    expect(heart.favouriteType, FavouriteType.product);
    expect(heart.itemId, 52);


    expect(heart.isFavourite, isTrue);
  });

  testWidgets('wires the cart button to this product', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester, <ProductModel>[offerProduct()]);

    final AnimatedCartButton cart = tester.widget(
      find.byType(AnimatedCartButton).first,
    );


    expect(cart.productId, 52);
    expect(cart.productQuantity, 0);
  });

  testWidgets('drops the discount badge and old price without a discount', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester, <ProductModel>[
      offerProduct(effectivePrice: null, discountPercentage: null),
    ]);


    expect(find.text('0%'), findsNothing);
    expect(find.text('20.00'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  // The first card used to touch the screen edge; it now sits as far in as
  // the All stores cards (16 + 5).
  testWidgets('the first card is inset from the reading-start edge', (
    WidgetTester tester,
  ) async {
    await pumpSection(tester, <ProductModel>[offerProduct(id: 1)]);

    final Finder card = find.byType(HomeNeverMissOffersItem).first;
    final Rect rect = tester.getRect(card);
    final double sectionWidth = tester
        .getSize(find.byType(HomeNeverMissOffersSection))
        .width;
    final double sectionLeft = tester
        .getTopLeft(find.byType(HomeNeverMissOffersSection))
        .dx;
    final bool rtl =
        Directionality.of(tester.element(card)) == TextDirection.rtl;

    final double inset = rtl
        ? sectionLeft + sectionWidth - rect.right
        : rect.left - sectionLeft;
    expect(inset, 21);
  });

  testWidgets('renders one card per product', (WidgetTester tester) async {
    await pumpSection(tester, <ProductModel>[
      offerProduct(id: 1, name: 'First'),
      offerProduct(id: 2, name: 'Second'),
    ]);


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


    await pumpSection(tester, <ProductModel>[offerProduct()]);

    expect(backdropGradient(tester).colors.first.a, 0.9);
    expect(viewAllChip(tester).textColor, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
