import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/top_brands/top_brands_item.dart';

class TopBrandsView extends StatelessWidget {
  const TopBrandsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(5),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.8
      ),
      itemCount: 6,
      itemBuilder: (BuildContext context, int index) => InkWell(
          onTap: () => context.pushNamed(AppRoutes.storeDetailsScreen),
          child: TopBrandsItem()),
    );
  }
}
