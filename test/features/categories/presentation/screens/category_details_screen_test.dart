import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_item.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/screens/category_details_screen.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_products_search_provider.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_products_vm.dart';

import '../../../../helpers/categories_test_harness.dart';

void main() {
  setUpAll(initCategoriesTestLocalization);

  List<Override> detailsOverrides() => <Override>[
        overrideCategoryProducts(
          AsyncValue<PaginationModel<ProductModel>>.data(
            pageOf<ProductModel>(<ProductModel>[sampleProduct(en: 'Pizza')]),
          ),
        ),
        overrideCategoryStores(
          AsyncValue<PaginationModel<StoreModel>>.data(
            pageOf<StoreModel>(<StoreModel>[sampleStore(en: 'Corner Shop')]),
          ),
        ),
      ];

  testWidgets('renders the category title, both tabs and the products content',
      (WidgetTester tester) async {
    await pumpCategoriesScreen(
      tester,
      CategoryDetailsScreen(category: sampleCategory(en: 'Food')),
      overrides: detailsOverrides(),
    );


    expect(find.text('Food'), findsOneWidget);

    expect(find.text('products'), findsOneWidget);
    expect(find.text('stores'), findsOneWidget);

    expect(find.byType(ProductItem3View), findsWidgets);
  });

  testWidgets('opened with only a slug, it takes the name from the categories',
      (WidgetTester tester) async {
    // What a banner or an offer linking a category opens: they carry no name,
    // and the app bar used to render blank.
    await pumpCategoriesScreen(
      tester,
      const CategoryDetailsScreen(category: CategoryModel(slug: 'food')),
      overrides: <Override>[
        ...detailsOverrides(),
        overrideAppCategories(
          AsyncValue<PaginationModel<CategoryModel>>.data(
            pageOf<CategoryModel>(<CategoryModel>[sampleCategory(en: 'Food')]),
          ),
        ),
      ],
    );

    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('its search terms are its own, not an outer screen\'s',
      (WidgetTester tester) async {
    // A category screen pushed over another (category -> store -> a banner
    // linking a category) used to open filtered by the one beneath.
    final List<CategoryProductsArgs> queried = <CategoryProductsArgs>[];
    await pumpCategoriesScreen(
      tester,
      CategoryDetailsScreen(category: sampleCategory(en: 'Food')),
      overrides: <Override>[
        overrideCategoryStores(
          AsyncValue<PaginationModel<StoreModel>>.data(
            pageOf<StoreModel>(<StoreModel>[]),
          ),
        ),
        categoryProductsSearchProvider.overrideWith((Ref ref) => 'leaked'),
        getCategoryProductsProvider.overrideWith(
          (Ref ref, CategoryProductsArgs args) {
            queried.add(args);
            return _IdleCategoryProductsVM(args);
          },
        ),
      ],
    );

    expect(queried.map((CategoryProductsArgs a) => a.searchKey), <String?>[
      null,
    ]);
  });

  testWidgets('switching to the Stores tab shows store items',
      (WidgetTester tester) async {
    await pumpCategoriesScreen(
      tester,
      CategoryDetailsScreen(category: sampleCategory(en: 'Food')),
      overrides: detailsOverrides(),
    );

    await tester.tap(find.text('stores'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));






    for (dynamic ex = tester.takeException();
        ex != null;
        ex = tester.takeException()) {
      expect(ex.toString(), contains('overflow'));
    }


    expect(find.byType(StoreItem), findsWidgets);
  });
}

class _IdleCategoryProductsVM extends GetCategoryProductsViewModel {
  _IdleCategoryProductsVM(CategoryProductsArgs args) : super(args: args) {
    state = AsyncValue<PaginationModel<ProductModel>>.data(
      pageOf<ProductModel>(<ProductModel>[sampleProduct()]),
    );
  }

  @override
  Future<void> loadFirstPage() async {}
}
