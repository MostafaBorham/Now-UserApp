import 'package:easy_localization/easy_localization.dart' as localization;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cards/product_item_card1.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cart/circular_cart_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/products/product_details_list_scope.dart';
import 'package:nowdelivery_user_app/core/routing/app_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/glass_product_item_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_never_miss_offers_item.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';
import 'package:nowdelivery_user_app/features/products/data/models/product_color_model.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_options_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/providers/product_details/product_quantity_provider.dart';
import 'package:nowdelivery_user_app/features/products/presentation/screens/product_details_overlay.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_body.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_main_info_card.dart';
import 'package:nowdelivery_user_app/features/products/viewmodel/get_product_details_vm.dart';

import '../../helpers/categories_test_harness.dart';

const _products = [
  ProductModel(id: 1, slug: 'one', name: {'en': 'First product'}, stock: 20),
  ProductModel(
    id: 2,
    slug: 'two',
    name: {'en': 'Second product'},
    stock: 20,
    minOrderQuantity: 3,
    colors: [
      ProductColorModel(hex: '#FF0000', name: {'en': 'Red'}),
    ],
  ),
  ProductModel(id: 3, slug: 'three', name: {'en': 'Third product'}, stock: 20),
  ProductModel(id: 4, slug: 'four', name: {'en': 'Fourth product'}, stock: 20),
];

class _DetailsVm extends GetProductDetailsViewModel {
  _DetailsVm(String slug, {bool longDetails = false})
    : super(
        AsyncData(
          _products
              .firstWhere((product) => product.slug == slug)
              .copyWith(
                mainFeatures: longDetails
                    ? List.generate(
                        30,
                        (index) => {'en': 'Product feature $index'},
                      )
                    : null,
              ),
        ),
        productSlug: slug,
      );

  @override
  Future<void> getProductDetails() async {}
}

void main() {
  setUpAll(initCategoriesTestLocalization);

  GoRoute detailsRoute() => AppRouter.router.configuration.routes
      .whereType<GoRoute>()
      .singleWhere((route) => route.name == AppRoutes.productDetailsScreen);

  Future<void> pumpSource(
    WidgetTester tester,
    Widget source, {
    bool longDetails = false,
  }) async {
    await pumpCategoriesScreen(
      tester,
      Scaffold(body: source),
      overrides: [
        getProductDetailsProvider.overrideWith(
          (ref, slug) => _DetailsVm(slug, longDetails: longDetails),
        ),
        getCartProvider.overrideWith(
          (ref) => GetCartViewModel(const AsyncData(CartModel())),
        ),
      ],
      destinationRoutes: [detailsRoute()],
    );
  }

  Widget openButton({Iterable<String?> Function()? slugs}) =>
      ProductDetailsListScope(
        productSlugs: slugs ?? () => _products.map((product) => product.slug),
        child: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => ProductDetailsListScope.open(context, 'two'),
              child: const Text('Open second'),
            ),
          ),
        ),
      );

  Finder page(String slug) => find.byWidgetPredicate(
    (widget) => widget is ProductDetailsBody && widget.productSlug == slug,
  );

  ProviderContainer containerOf(WidgetTester tester, String slug) =>
      ProviderScope.containerOf(
        tester.element(
          find.descendant(
            of: page(slug),
            matching: find.byType(ProductMainInfoCard),
          ),
        ),
        listen: false,
      );

  testWidgets(
    'scroll expands to full screen and reverses at the same offsets',
    (tester) async {
      tester.view.viewPadding = const FakeViewPadding(top: 30, bottom: 20);
      addTearDown(tester.view.resetViewPadding);
      await pumpSource(tester, openButton(), longDetails: true);
      await tester.tap(find.text('Open second'));
      await tester.pumpAndSettle();
      final surface = find.byKey(const ValueKey('product-details-surface-1'));
      final original = tester.getRect(surface);
      final scroll = tester
          .widgetList<SingleChildScrollView>(
            find.descendant(
              of: page('two'),
              matching: find.byType(SingleChildScrollView),
            ),
          )
          .singleWhere((view) => view.controller != null)
          .controller!;
      final state = containerOf(tester, 'two');
      state.read(productQuantityProvider.notifier).state = 4;

      scroll.jumpTo(80);
      await tester.pumpAndSettle();
      final halfway = tester.getRect(surface);
      expect(halfway.width, greaterThan(original.width));
      expect(halfway.width, lessThan(390));
      expect(halfway.height, greaterThan(original.height));
      expect(halfway.top, greaterThan(0));

      scroll.jumpTo(160);
      await tester.pumpAndSettle();
      final full = tester.getRect(surface);
      expect(full.left, closeTo(0, 0.01));
      expect(full.top, closeTo(0, 0.01));
      expect(full.width, closeTo(390, 0.01));
      expect(full.height, closeTo(844, 0.01));
      expect(
        tester.getTopLeft(find.byType(CloseButton).hitTestable().first).dy,
        greaterThanOrEqualTo(30),
      );
      scroll.jumpTo(320);
      await tester.pumpAndSettle();
      expect(tester.getRect(surface), full);

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      final nextSurface = find.byKey(
        const ValueKey('product-details-surface-2'),
      );
      expect(tester.getRect(nextSurface), original);
      await tester.drag(find.byType(PageView), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(tester.getRect(surface), full);
      expect(scroll.offset, 320);

      scroll.jumpTo(80);
      await tester.pumpAndSettle();
      expect(tester.getRect(surface), halfway);
      scroll.jumpTo(0);
      await tester.pumpAndSettle();
      expect(tester.getRect(surface), original);
      expect(state.read(productQuantityProvider), 4);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('centers tapped product, peeks neighbors, swipes both ways', (
    tester,
  ) async {
    await pumpSource(tester, openButton());
    await tester.tap(find.text('Open second'));
    await tester.pumpAndSettle();

    final pager = tester.widget<PageView>(find.byType(PageView));
    expect(pager.controller!.viewportFraction, 0.9);
    expect(pager.controller!.page, 1);
    expect(tester.getCenter(page('two')).dx, closeTo(195, 1));
    expect(tester.getRect(page('one')).right, greaterThan(0));
    expect(tester.getRect(page('three')).left, lessThan(390));
    expect(
      tester.getSize(page('one')).height,
      lessThan(tester.getSize(page('two')).height),
    );
    expect(
      tester.getSize(page('three')).height,
      lessThan(tester.getSize(page('two')).height),
    );
    expect(tester.getRect(find.byType(PageView)).top, 16);
    expect(tester.getRect(find.byType(PageView)).bottom, 844 - 16);

    await tester.drag(find.byType(PageView), const Offset(-350, 0));
    await tester.pumpAndSettle();
    expect(pager.controller!.page, 2);
    expect(
      tester.getSize(page('two')).height,
      lessThan(tester.getSize(page('three')).height),
    );
    await tester.drag(find.byType(PageView), const Offset(350, 0));
    await tester.pumpAndSettle();
    expect(pager.controller!.page, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('short details can expand and shrink with vertical gestures', (
    tester,
  ) async {
    await pumpSource(tester, openButton());
    await tester.tap(find.text('Open second'));
    await tester.pumpAndSettle();
    final surface = find.byKey(const ValueKey('product-details-surface-1'));
    final original = tester.getRect(surface);
    final scroll = find
        .descendant(
          of: page('two'),
          matching: find.byType(SingleChildScrollView),
        )
        .first;
    await tester.drag(scroll, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.getRect(surface).width, closeTo(390, 0.01));
    expect(tester.getRect(surface).height, closeTo(844, 0.01));
    await tester.drag(scroll, const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(tester.getRect(surface), original);
    expect(tester.takeException(), isNull);
  });

  testWidgets('slides up from the bottom and slides down on close', (
    tester,
  ) async {
    await pumpSource(tester, openButton());
    await tester.tap(find.text('Open second'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final openingTop = tester.getTopLeft(find.byType(PageView)).dy;
    expect(openingTop, greaterThan(16));
    await tester.pump(const Duration(milliseconds: 80));
    expect(tester.getTopLeft(find.byType(PageView)).dy, lessThan(openingTop));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(PageView)).dy, 16);

    final close = find.byType(CloseButton).hitTestable().first;
    final circularMaterial = tester
        .widgetList<Material>(
          find.ancestor(of: close, matching: find.byType(Material)),
        )
        .where((material) => material.shape is CircleBorder)
        .single;
    expect(circularMaterial.elevation, 3);
    expect(circularMaterial.color, Colors.white);
    await tester.tap(close);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getTopLeft(find.byType(PageView)).dy, greaterThan(16));
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailsOverlay), findsNothing);
  });

  testWidgets('keeps each product quantity and options when swiping away', (
    tester,
  ) async {
    await pumpSource(tester, openButton());
    await tester.tap(find.text('Open second'));
    await tester.pumpAndSettle();
    final second = containerOf(tester, 'two');
    expect(second.read(productQuantityProvider), 3);
    expect(second.read(productOptionsProvider(2)).colorHex, '#FF0000');
    await tester.tap(
      find.descendant(of: page('two'), matching: find.byIcon(Icons.add)),
    );
    second.read(productOptionsProvider(2).notifier).selectColor('#0000FF');
    await tester.pump();
    expect(second.read(productQuantityProvider), 4);

    await tester.drag(find.byType(PageView), const Offset(-350, 0));
    await tester.pumpAndSettle();
    final third = containerOf(tester, 'three');
    expect(third.read(productQuantityProvider), 1);
    expect(third.read(productOptionsProvider(3)).colorHex, isNull);
    await tester.drag(find.byType(PageView), const Offset(-350, 0));
    await tester.pumpAndSettle();
    final pager = tester.widget<PageView>(find.byType(PageView));
    pager.controller!.jumpToPage(1);
    await tester.pumpAndSettle();
    final returned = containerOf(tester, 'two');
    expect(returned.read(productQuantityProvider), 4);
    expect(returned.read(productOptionsProvider(2)).colorHex, '#0000FF');
  });

  testWidgets('dismisses to the same list and preserves its scroll position', (
    tester,
  ) async {
    final scroll = ScrollController(initialScrollOffset: 120);
    addTearDown(scroll.dispose);
    await pumpSource(
      tester,
      ListView(
        controller: scroll,
        children: [
          const SizedBox(height: 200),
          SizedBox(height: 100, child: openButton()),
          const SizedBox(height: 1200),
        ],
      ),
    );
    await tester.tap(find.text('Open second'));
    await tester.pumpAndSettle();
    expect(find.text('Open second'), findsOneWidget);
    // The visible page's close button is nearest the center of the viewport.
    await tester.tap(find.byType(CloseButton).hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailsOverlay), findsNothing);
    expect(scroll.offset, 120);
    expect(find.text('Open second'), findsOneWidget);
  });

  testWidgets('Arabic swipes follow reading order and system back closes', (
    tester,
  ) async {
    await pumpSource(tester, openButton());
    await localization.EasyLocalization.of(
      tester.element(find.text('Open second')),
    )!.setLocale(const Locale('ar', 'EG'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open second'));
    await tester.pumpAndSettle();
    final pager = tester.widget<PageView>(find.byType(PageView));
    expect(pager.controller!.page, 1);
    expect(tester.getCenter(page('two')).dx, closeTo(195, 1));
    await tester.drag(find.byType(PageView), const Offset(350, 0));
    await tester.pumpAndSettle();
    expect(pager.controller!.page, 2);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailsOverlay), findsNothing);
    await localization.EasyLocalization.of(
      tester.element(find.text('Open second')),
    )!.setLocale(const Locale('en', 'US'));
    await tester.pumpAndSettle();
  });

  testWidgets('cart action closes the overlay and selects the cart tab', (
    tester,
  ) async {
    await pumpSource(tester, openButton());
    final container = ProviderScope.containerOf(
      tester.element(find.text('Open second')),
      listen: false,
    );
    final tabSubscription = container.listen(mainTabIndexProvider, (_, _) {});
    addTearDown(tabSubscription.close);
    await tester.tap(find.text('Open second'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CircularCartButton).hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailsOverlay), findsNothing);
    expect(container.read(mainTabIndexProvider), 2);
  });

  for (final style in ['grid', 'store', 'glass', 'offer']) {
    testWidgets('$style card forwards the surrounding product list', (
      tester,
    ) async {
      final product = _products[1];
      final card = switch (style) {
        'grid' => ProductItem3View(product: product),
        'store' => ProductItemCard1(product: product),
        'glass' => GlassProductItemView(product: product),
        _ => HomeNeverMissOffersItem(product: product),
      };
      await pumpSource(
        tester,
        ProductDetailsListScope(
          productSlugs: () => _products.map((product) => product.slug),
          child: Center(child: SizedBox(width: 190, height: 300, child: card)),
        ),
      );
      await tester.tap(
        find
            .descendant(of: find.byWidget(card), matching: find.byType(InkWell))
            .first,
      );
      await tester.pumpAndSettle();
      final overlay = tester.widget<ProductDetailsOverlay>(
        find.byType(ProductDetailsOverlay),
      );
      expect(overlay.productSlugs, ['one', 'two', 'three', 'four']);
      expect(overlay.initialIndex, 1);
    });
  }

  testWidgets(
    'reads newly loaded products at tap time and ignores invalid slugs',
    (tester) async {
      final slugs = <String?>['one', 'two'];
      await pumpSource(tester, openButton(slugs: () => slugs));
      slugs.addAll(['three', null, '', 'two']);
      await tester.tap(find.text('Open second'));
      await tester.pumpAndSettle();
      final overlay = tester.widget<ProductDetailsOverlay>(
        find.byType(ProductDetailsOverlay),
      );
      expect(overlay.productSlugs, ['one', 'two', 'three']);
      expect(overlay.initialIndex, 1);
    },
  );

  testWidgets('single product links still open a dismissible overlay', (
    tester,
  ) async {
    await pumpSource(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () =>
              context.pushNamed(AppRoutes.productDetailsScreen, extra: 'one'),
          child: const Text('Banner'),
        ),
      ),
    );
    await tester.tap(find.text('Banner'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ProductDetailsOverlay>(find.byType(ProductDetailsOverlay))
          .productSlugs,
      ['one'],
    );
    await tester.tapAt(const Offset(195, 8));
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailsOverlay), findsNothing);
  });
}
