import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/enums/product_filters.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cards/product_item_card1.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_store_category_products_vm.dart';

/// One category of **one store**, reached from the category chips on that
/// store's details screen.
///
/// It pages `/api/v1/stores/{storeId}/products?category_id=…` through
/// [getStoreCategoryProductsProvider] — the same provider and the same card as
/// the store details product grid, so a product looks and behaves identically
/// wherever it is listed. It used to reuse the *categories* feature's product
/// view, which queries `/api/v1/categories/{slug}/products` and is not scoped to
/// a store at all: under a heading naming the store's categories it listed that
/// category across every store on the platform.
class ViewStoreCategoryProductsScreen extends ConsumerStatefulWidget {
  const ViewStoreCategoryProductsScreen({
    super.key,
    required this.storeId,
    required this.categoryId,
    this.categoryName,
  });

  /// `null` when the route could not name a store — the screen then shows its
  /// "unavailable" state instead of asking the API for a store it cannot name.
  final int? storeId;

  /// `null` when the route could not name a category, handled the same way.
  final int? categoryId;

  /// Localized name passed from the tapped chip, used as the app bar title.
  final Map<String, dynamic>? categoryName;

  @override
  ConsumerState<ViewStoreCategoryProductsScreen> createState() =>
      _ViewStoreCategoryProductsScreenState();
}

class _ViewStoreCategoryProductsScreenState
    extends ConsumerState<ViewStoreCategoryProductsScreen> {
  static const SliverGridDelegate _gridDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.6,
      );

  /// The settled search term. Plain local state: the field debounces and hands
  /// back the term, and it only ever feeds this screen's query.
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final int? storeId = widget.storeId;
    final int? categoryId = widget.categoryId;
    final String title = widget.categoryName == null
        ? LangKeys.storeCategoriesKey.tr()
        : context.getLocalizedApiText(widget.categoryName);

    if (storeId == null || categoryId == null) {
      return Scaffold(
        body: AppWavedView(
          body: const Padding(
            padding: EdgeInsets.all(16.0),
            child: ServerConnectionErrorWidget(
              message: LangKeys.storeUnavailableKey,
            ),
          ),
          appBarTitle: title,
          canPop: context.canPop(),
        ),
      );
    }

    final StoreCategoryProductsArgs args = (
      storeId: storeId,
      categoryId: categoryId,
      filter: ProductFilters.defaultFilter,
      searchKey: _search.isEmpty ? null : _search,
    );
    final GetStoreCategoryProductsViewModel viewModel = ref.read(
      getStoreCategoryProductsProvider(args).notifier,
    );

    return Scaffold(
      body: AppWavedView(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: <Widget>[
            // The field debounces internally and hands back the settled term;
            // storing it re-queries the grid as a new family member with its
            // own pagination state.
            PrimarySearchField(
              isAnimated: false,
              onSearch: (String query) {
                if (query == _search) return;
                setState(() => _search = query);
              },
            ),
            Expanded(
              child: PaginatedView<ProductModel>(
                provider: getStoreCategoryProductsProvider(args),
                onRefresh: viewModel.loadFirstPage,
                onLoadNextPage: viewModel.loadNextPage,
                layout: const PaginatedGridLayout(
                  gridDelegate: _gridDelegate,
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
                placeholderBuilder: (BuildContext context) =>
                    const AppShimmer(child: ProductItemCard1()),
                itemBuilder:
                    (BuildContext context, ProductModel product, int index) =>
                        ProductItemCard1(
                          product: product,
                          onFavouriteChanged: (bool isFavourite) => viewModel
                              .updateProductFavourite(product.id, isFavourite),
                        ),
              ),
            ),
          ],
        ),
        appBarTitle: title,
        canPop: context.canPop(),
      ),
    );
  }
}
