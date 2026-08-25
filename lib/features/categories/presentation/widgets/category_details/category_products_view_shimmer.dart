import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

/// First-load skeleton for [CategoryProductsView]: a grid of shimmering product
/// cards laid out exactly like the real products, so the loading state matches
/// their geometry.
class CategoryProductsViewShimmer extends StatelessWidget {
  const CategoryProductsViewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (BuildContext context, int index) =>
          const AppShimmer(child: ProductItem3View()),
    );
  }
}
