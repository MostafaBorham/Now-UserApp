import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/categories_product_shimmer_view.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_categories_vm.dart';
import 'package:nowdelivery_user_app/features/products/data/models/product_model.dart'
    hide CategoryModel;
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_item_card2.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/features/products/viewmodel/get_products_vm.dart';

class CategoriesProductTabView extends ConsumerStatefulWidget {
  const CategoriesProductTabView({super.key});

  @override
  ConsumerState<CategoriesProductTabView> createState() =>
      _CategoriesProductTabViewState();
}

class _CategoriesProductTabViewState
    extends ConsumerState<CategoriesProductTabView> {
  late final GetCategoriesViewModel _categoriesViewModel;
  // late final GetProductsViewModel _productsViewModel;
  int? filterCategoryId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _categoriesViewModel = ref.read(getCategoriesProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _fetchFilteredProducts();
    });
  }

  void _fetchFilteredProducts() {
    print('=== $filterCategoryId');
    final productsViewModel = ref.read(
      getProductsByCategoryFilterProvider(filterCategoryId).notifier,
    );
    productsViewModel.getProducts(categoryId: filterCategoryId);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final filterCategoriesState = ref.watch(getCategoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        AppSearchField(hintText: LangKeys.searchForAProductKey.tr()),
        Text(
          LangKeys.filtersKey.tr(),
          style: AppTextStyles.style14SemiBold.copyWith(
            color: colors.onSecondary,
          ),
        ),
        Expanded(
          child: filterCategoriesState.when(
            loading: () => CategoriesProductShimmerView(),
            error: (Object error, StackTrace stackTrace) =>
                ServerConnectionErrorWidget(
                  message: error.toString(),
                  onRetry: () => _categoriesViewModel.getCategories(),
                ),
            data: (filterCategories) {
              final filterItems = [
                CategoryModel(
                  name: LangKeys.allKey.tr(),
                  slug: LangKeys.allKey.tr(),
                ),
                ...filterCategories,
              ];
              return CustomButtonTabBar(
                onTap: (index) {
                  print('current = $index');
                  filterCategoryId = filterItems.elementAt(index).id;
                  _fetchFilteredProducts();
                },
                tabs: filterItems.map((filter) => filter.name).toList(),
                views: filterItems.map((e) {
                  return ref
                      .watch(getProductsByCategoryFilterProvider(e.id))
                      .when(
                        data: (products) {
                          return GridView.builder(
                            padding: EdgeInsets.all(4),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: 0.75,
                                ),
                            itemCount: 5,
                            itemBuilder: (BuildContext context, int index) {
                              // return Container(color: colors.error);
                              return ProductItemCard2(
                                // productModel: products.elementAtOrNull(index),
                              );
                            },
                          );
                        },
                        error: (error, stackTrace) {
                          return ServerConnectionErrorWidget(
                            message: error.toString(),
                            onRetry: () => _fetchFilteredProducts(),
                          );
                        },
                        loading: () {
                          return GridView.builder(
                            padding: EdgeInsets.all(4),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 20,
                                  childAspectRatio: 0.75,
                                ),
                            itemCount: 4,
                            itemBuilder: (BuildContext context, int index) {
                              return AppShimmer(
                                child: ProductItemCard2(
                                  // productModel: products.elementAtOrNull(index),
                                ),
                              );
                              return ProductItemCard2(
                                // productModel: products.elementAtOrNull(index),
                              );
                            },
                          );
                        },
                      );
                }).toList(),
                selectedLabelColor: colors.onSecondary,
                selectedTabColor: colors.secondary,
                unSelectedTabColor: colors.inversePrimary.withValues(
                  alpha: 0.2,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
