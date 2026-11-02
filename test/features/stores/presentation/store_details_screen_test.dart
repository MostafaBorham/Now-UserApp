import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cards/product_item_card1.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/top_wave_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/screens/store_details_screen.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_store_category_products_vm.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_store_details_vm.dart';

import '../../../helpers/categories_test_harness.dart';

class _FakeStore extends GetStoreDetailsViewModel {
  _FakeStore(StoreModel store)
    : super(AsyncValue<StoreModel>.data(store), storeId: store.id!);

  @override
  Future<void> getStoreDetails() async {}
}

/// A store with [total] products, served 20 a page; records the pages asked.
class _FakeProducts extends GetStoreCategoryProductsViewModel {
  _FakeProducts(StoreCategoryProductsArgs args, this.total) : super(args: args);

  static const int _perPage = 20;
  final int total;
  final List<int> pages = <int>[];

  @override
  Future<Either<Failure, PaginationModel<ProductModel>>> fetchPage(
    int page,
  ) async {
    pages.add(page);
    final int lastPage = (total / _perPage).ceil();
    final int from = (page - 1) * _perPage;
    final int to = (from + _perPage).clamp(0, total);
    return Right<Failure, PaginationModel<ProductModel>>(
      PaginationModel<ProductModel>(
        currentPage: page,
        lastPage: lastPage,
        perPage: _perPage,
        total: total,
        hasMore: page < lastPage,
        data: <ProductModel>[
          for (int id = from + 1; id <= to; id++)
            sampleProduct(id: id, en: 'Product $id'),
        ],
      ),
    );
  }
}

/// BUG-017 / QA-030 S16: the store page is one scroll view, so it ends at its
/// last product; the tab row pins and the grid still pages.
void main() {
  setUpAll(() async {
    await initCategoriesTestLocalization();
    await SharedPrefManager.init();
  });

  Future<_FakeProducts> pumpStore(WidgetTester tester, int total) async {
    late _FakeProducts products;
    await pumpCategoriesScreen(
      tester,
      const StoreDetailsScreen(storeId: 1),
      overrides: <Override>[
        getStoreDetailsProvider.overrideWith(
          (Ref ref, int id) => _FakeStore(sampleStore(id: id)),
        ),
        getStoreCategoryProductsProvider.overrideWith(
          (Ref ref, StoreCategoryProductsArgs args) =>
              products = _FakeProducts(args, total)..loadFirstPage(),
        ),
      ],
    );
    await tester.pump();
    return products;
  }

  ScrollPosition pagePosition(WidgetTester tester) => tester
      .state<ScrollableState>(
        find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      )
      .position;

  Future<void> scrollTo(WidgetTester tester, double offset) async {
    pagePosition(tester).jumpTo(offset);
    await tester.pump();
  }

  testWidgets('two products: the page ends at the last row', (
    WidgetTester tester,
  ) async {
    await pumpStore(tester, 2);
    // A phone short enough that header, tabs and one row don't fit.
    tester.view.physicalSize = const Size(390, 600);
    await tester.pump();

    final ScrollPosition position = pagePosition(tester);
    expect(position.maxScrollExtent, greaterThan(0));
    await scrollTo(tester, position.maxScrollExtent);

    // Only the grid's own 5 dp padding under the last row; the old
    // NestedScrollView scrolled the header away over a screen of white.
    final double pageBottom = tester
        .getRect(find.byType(CustomScrollView))
        .bottom;
    final double lastRowBottom = tester
        .getRect(find.byType(ProductItemCard1).last)
        .bottom;
    expect(pageBottom - lastRowBottom, moreOrLessEquals(5));
  });

  testWidgets('forty products: the tab row pins and page 2 loads', (
    WidgetTester tester,
  ) async {
    final _FakeProducts products = await pumpStore(tester, 40);
    expect(products.pages, <int>[1]);

    // Pinned below the wave, not at the scroll view's top under it.
    await scrollTo(tester, 800);
    final Rect page = tester.getRect(find.byType(CustomScrollView));
    expect(
      tester.getTopLeft(find.byType(CustomButtonTabBar)).dy,
      moreOrLessEquals(page.top + TopWaveClipper.depthFor(page.width)),
    );

    await scrollTo(tester, pagePosition(tester).maxScrollExtent);
    await tester.pump();
    expect(products.pages, <int>[1, 2]);
    expect(products.state.value?.data, hasLength(40));
  });
}
