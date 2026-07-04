import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_item_card1.dart';

class OffersCannotWaitView extends StatelessWidget {
  const OffersCannotWaitView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 5),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.65
      ),
      itemCount: 6,
      itemBuilder: (BuildContext context, int index) => ProductItemCard1(),
    );
  }
}