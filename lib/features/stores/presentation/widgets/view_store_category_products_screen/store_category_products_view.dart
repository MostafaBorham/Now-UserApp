import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_item_card2.dart';

class StoreCategoryProductsView extends StatelessWidget {
  const StoreCategoryProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder:
          (BuildContext context, int index) =>
          ProductItemCard2(),
    );
  }
}
