import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cards/product_item_card1.dart';

class StoreDetailsProductsView extends StatelessWidget {
  const StoreDetailsProductsView({
    super.key,
    required this.products,
    required this.sortType,
    this.onProductFavouriteChanged,
  });

  final List<ProductModel> products;
  final StoresSortType sortType;

  /// Called with a product's id and its new favourite status after a settled
  /// toggle on that product's card, so the store-details provider can persist
  /// the change onto the store's product list.
  final void Function(int? productId, bool isFavourite)?
      onProductFavouriteChanged;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      // Fill the tab view and centre the empty state. Sizing it to exactly the
      // viewport (minHeight == maxHeight in the isScrollable path) means the
      // content itself never scrolls, while still giving the NestedScrollView the
      // scrollable it needs to collapse the header and pin the tab bar to the top.
      return const NoResultsWidget(isScrollable: true);
    }
    return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 5),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 18,
          mainAxisSpacing: 16,
          // Design card: 170 x 280.
          childAspectRatio: 170 / 280
      ),
      itemCount: products.length,
      itemBuilder: (BuildContext context, int index) => ProductItemCard1(
        product: products[index],
        onFavouriteChanged: (bool isFavourite) =>
            onProductFavouriteChanged?.call(products[index].id, isFavourite),
      ),
    );
  }
}
