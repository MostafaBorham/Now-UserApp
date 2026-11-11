import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/constants.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_themes.dart';
import 'package:nowdelivery_user_app/core/routing/app_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/products/data/models/product_color_model.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_body.dart';
import 'package:nowdelivery_user_app/features/products/viewmodel/get_product_details_vm.dart';

/// Deterministic rendering benchmark; seeded products avoid network variance.
/// Uses the real overlay route and keeps the installed app/session afterwards.
///
/// PERF_LABEL=details-before flutter drive --profile --no-dds --keep-app-running
///   --driver=test_driver/perf_driver.dart
///   --target=integration_test/product_details_perf_test.dart -d DEVICE_ID
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('product details rendering performance', (tester) async {
    await EasyLocalization.ensureInitialized();
    final route = AppRouter.router.configuration.routes
        .whereType<GoRoute>()
        .singleWhere((route) => route.name == AppRoutes.productDetailsScreen);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) => ListTile(
                title: Text('Product ${index + 1}'),
                subtitle: const Text('Product details animation benchmark'),
              ),
            ),
          ),
        ),
        route,
      ],
    );
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: LocalizationConstants.supportedLocales,
        path: LocalizationConstants.languagesPath,
        startLocale: LocalizationConstants.englishLocale,
        fallbackLocale: LocalizationConstants.englishLocale,
        saveLocale: false,
        child: ProviderScope(
          overrides: [
            getProductDetailsProvider.overrideWith(
              (ref, slug) => _DetailsVm(slug),
            ),
            getCartProvider.overrideWith(
              (ref) => GetCartViewModel(const AsyncData(CartModel())),
            ),
          ],
          child: Builder(
            builder: (context) => MaterialApp.router(
              theme: AppThemes.getLightModeTheme(),
              routerConfig: router,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(seconds: 1));
    await tester.pump();

    void open() => unawaited(
      router.pushNamed(
        AppRoutes.productDetailsScreen,
        extra: <String, Object>{
          'productSlugs': ['one', 'two', 'three'],
          'initialIndex': 1,
        },
      ),
    );

    Future<void> settleRoute() async {
      await Future<void>.delayed(const Duration(milliseconds: 750));
      await tester.pump();
    }

    await binding.watchPerformance(() async {
      open();
      await settleRoute();
      router.pop();
      await settleRoute();
    }, reportKey: 'details_cold_open_close');

    await binding.watchPerformance(() async {
      for (int i = 0; i < 5; i++) {
        open();
        await settleRoute();
        router.pop();
        await settleRoute();
      }
    }, reportKey: 'details_open_close');

    open();
    await settleRoute();
    final body = find.byWidgetPredicate(
      (widget) => widget is ProductDetailsBody && widget.productSlug == 'two',
    );
    final scroll = tester
        .widget<CustomScrollView>(
          find.descendant(of: body, matching: find.byType(CustomScrollView)),
        )
        .controller!;
    await binding.watchPerformance(() async {
      for (int i = 0; i < 8; i++) {
        await scroll.animateTo(
          150,
          duration: const Duration(milliseconds: 400),
          curve: Curves.linear,
        );
        await scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.linear,
        );
      }
      await tester.pump();
    }, reportKey: 'details_expand_collapse');
    router.pop();
    await settleRoute();
  });
}

class _DetailsVm extends GetProductDetailsViewModel {
  _DetailsVm(String slug)
    : super(
        AsyncData(
          ProductModel(
            id: ['one', 'two', 'three'].indexOf(slug) + 1,
            slug: slug,
            name: {'en': 'Product $slug with a longer descriptive title'},
            description: {'en': 'Product description. ' * 15},
            images: const ['', '', ''],
            stock: 20,
            price: 149.95,
            colors: const [
              ProductColorModel(hex: '#FF0000', name: {'en': 'Red'}),
              ProductColorModel(hex: '#0000FF', name: {'en': 'Blue'}),
            ],
            mainFeatures: List.generate(
              30,
              (index) => {
                'en': 'Feature $index: quality, comfort and durability',
              },
            ),
          ),
        ),
        productSlug: slug,
      );

  @override
  Future<void> getProductDetails() async {}
}
