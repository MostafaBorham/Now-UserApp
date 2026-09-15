import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

class CategoryProductsViewShimmer extends StatelessWidget {
  const CategoryProductsViewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints con) {
        return GridView.builder(
          padding: const EdgeInsets.all(2),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: con.maxWidth * 0.03,
            mainAxisSpacing: con.maxWidth * 0.03,
            childAspectRatio: 0.7,
          ),
          itemCount: 6,
          itemBuilder: (BuildContext context, int index) =>
              const AppShimmer(child: ProductItem3View()),
        );
      },
    );
  }
}
