import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';

class ProductsImagesListView extends StatelessWidget {
  const ProductsImagesListView({super.key, this.products});

  /// Products whose images are previewed (first 3, then a "+" tile for the
  /// rest). Falls back to the static placeholder tiles when null.
  final List<ProductModel>? products;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final List<ProductModel>? items = products;
    return Row(
      spacing: 8,
      children: [
        if (items == null)
          for (int i = 0; i < 2; i++)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 56,
                height: 56,
                child: AppCachedNetworkImage(
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  imageUrl:
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTruTN7TKhs6EbZtBGtXkJjLwrXau6sw1eyrA&s',
                ),
              ),
            )
        else
          for (final ProductModel product in items.take(3))
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 56,
                height: 56,
                child: AppCachedNetworkImage(
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  imageUrl: product.primaryImage ??
                      (product.images.isNotEmpty ? product.images.first : ''),
                ),
              ),
            ),
        if (items == null || items.length > 3)
          Container(
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
      ],
    );
  }
}
