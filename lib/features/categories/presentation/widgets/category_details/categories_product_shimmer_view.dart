import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_products_view.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_products_view_shimmer.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_item_card2.dart';

class CategoriesProductShimmerView extends StatelessWidget {
  const CategoriesProductShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Row(
          spacing: 6,
          children: List.generate(
            4,
                (index) => Expanded(
              child: AppShimmer(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppBorderRadius.brCircular20,
                  ),
                  child: const Text(
                    'All',
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: CategoryProductsViewShimmer(),
        )
      ],
    );
  }
}
