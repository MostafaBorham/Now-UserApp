import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_item_card2.dart';

class CategoryProductsViewShimmer extends StatelessWidget {
  const CategoryProductsViewShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
        // return Container(color: colors.error);
        return AppShimmer(
          child: ProductItemCard2(
            onTap: () {

            },
            // productModel: products.elementAtOrNull(index),
          ),
        );
      },
    );
  }
}