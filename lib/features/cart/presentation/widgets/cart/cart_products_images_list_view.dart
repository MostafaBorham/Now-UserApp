import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

/// The collapsed body of a store's cart card: its lines as thumbnails, plus a
/// tile back into the store to add more.
class CartProductsImagesListView extends StatelessWidget {
  const CartProductsImagesListView({
    super.key,
    required this.products,
    this.storeId,
    this.storeName,
  });

  final List<ProductModel> products;

  /// `null` leaves the "+" tile inert — there is no store to open.
  final int? storeId;

  /// Localized store name forwarded to store details for the loading app bar.
  final Map<String, dynamic>? storeName;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Wrap(
      runSpacing: 8,
      spacing: 8,
      children: [
        for (final ProductModel product in products)
          Container(
            width: 56,
            height: 56,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              boxShadow: AppBoxShadows.greyElevation3,
            ),
            child: AppCachedNetworkImage(
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              imageUrl: product.images?.firstOrNull ?? '',
            ),
          ),
        InkWell(
          onTap: storeId == null
              ? null
              : () => context.pushNamed(
                  AppRoutes.storeDetailsScreen,
                  pathParameters: <String, String>{'id': '$storeId'},
                  extra: storeName,
                ),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '+',
                style: AppTextStyles.style28Medium.copyWith(
                  color: colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
