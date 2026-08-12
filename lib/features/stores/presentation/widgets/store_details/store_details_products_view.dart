import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cards/product_item_card1.dart';

class StoreDetailsProductsView extends StatelessWidget {
  const StoreDetailsProductsView({
    super.key,
    required this.products,
    required this.sortType,
  });

  final List<ProductModel> products;
  final StoresSortType sortType;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const NoItemsWidget();
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
      itemBuilder: (BuildContext context, int index) =>
          ProductItemCard1(product: products[index]),
    );
  }
}
