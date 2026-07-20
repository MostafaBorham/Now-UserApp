import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';

class ProductsImagesListView extends StatelessWidget {
  const ProductsImagesListView({super.key, this.products, this.storeId});

  final List<ProductModel>? products;
  final int? storeId;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Wrap(
      runSpacing: 8,
      spacing: 8,
      children: [
        ...((products ?? [])
            .map(
              (product) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: AppCachedNetworkImage(
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    imageUrl: product.imageUrl ?? '',
                  ),
                ),
              ),
            )
            .toList()),
        InkWell(
          onTap: () => context.pushNamed(AppRoutes.storeDetailsScreen,extra: storeId),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.onPrimary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '+',
                style: AppTextStyles.style28Medium.copyWith(
                  color: colors.onSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
