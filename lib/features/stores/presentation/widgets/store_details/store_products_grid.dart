import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_item_card1.dart';

class StoreProductsGrid extends StatelessWidget {
  const StoreProductsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 8,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 170 / 262,
      ),
      itemBuilder: (_, _) => const ProductItemCard1(),
    );
  }
}
