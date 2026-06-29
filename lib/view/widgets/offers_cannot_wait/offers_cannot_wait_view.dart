import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/widgets/offers_cannot_wait/offers_cannot_wait_item_card.dart';
import 'package:nowdelivery_user_app/view/widgets/top_brands/top_brands_item.dart';

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
      itemBuilder: (BuildContext context, int index) => OffersCannotWaitItemCard(),
    );
  }
}