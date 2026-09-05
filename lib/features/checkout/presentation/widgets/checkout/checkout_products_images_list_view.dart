import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

/// The collapsed preview of a store's items: up to [_maxThumbnails] product
/// thumbnails followed by a "+" tile that expands the card into the full
/// item list (same action as the header chevron).
class CheckoutProductsImagesListView extends StatelessWidget {
  const CheckoutProductsImagesListView({super.key, this.items, this.onMoreTap});

  final List<ProductModel>? items;

  /// Tapping the trailing "+" tile. Null hides the tile.
  final VoidCallback? onMoreTap;

  static const int _maxThumbnails = 2;
  static const double _tileSize = 56;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final List<ProductModel> products = items ?? const <ProductModel>[];
    final List<ProductModel> visible = products.take(_maxThumbnails).toList();

    return Wrap(
      runSpacing: 8,
      spacing: 8,
      children: <Widget>[
        for (final ProductModel product in visible)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: _tileSize,
              height: _tileSize,
              child: AppCachedNetworkImage(
                width: _tileSize,
                height: _tileSize,
                fit: BoxFit.cover,
                imageUrl: product.images?.firstOrNull ?? '',
              ),
            ),
          ),
        if (onMoreTap != null)
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onMoreTap,
            child: Container(
              width: _tileSize,
              height: _tileSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.add, size: 20, color: colors.tertiaryContainer),
            ),
          ),
      ],
    );
  }
}
