import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';

class CheckoutProductsImagesListView extends StatelessWidget {
  const CheckoutProductsImagesListView({super.key, this.items});

  final List<ProductModel>? items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 8,
      spacing: 8,
      children: (items ?? const <ProductModel>[])
          .map(
            (item) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 56,
                height: 56,
                child: AppCachedNetworkImage(
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  imageUrl: '',
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
