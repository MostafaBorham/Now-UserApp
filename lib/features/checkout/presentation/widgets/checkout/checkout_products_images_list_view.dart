import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';




class CheckoutProductsImagesListView extends StatelessWidget {
  const CheckoutProductsImagesListView({super.key, this.items});

  final List<ProductModel>? items;

  static const int _maxThumbnails = 2;
  static const double _tileSize = 56;

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> products = items ?? const <ProductModel>[];
    final List<ProductModel> visible = products.take(_maxThumbnails).toList();

    return Wrap(
      runSpacing: 8,
      spacing: 8,
      children: <Widget>[
        for (final ProductModel product in visible)
          Container(
            width: _tileSize,
            height: _tileSize,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              boxShadow: AppBoxShadows.greyElevation3,
            ),
            child: AppCachedNetworkImage(
              width: _tileSize,
              height: _tileSize,
              fit: BoxFit.cover,
              imageUrl: product.images?.firstOrNull ?? '',
            ),
          ),
      ],
    );
  }
}
