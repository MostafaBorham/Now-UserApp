import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';

/// One of the store's own banners. Built under the store page's scope, so
/// [storeProvider] is the store it advertises.
class StoreDetailsBanner extends ConsumerWidget {
  const StoreDetailsBanner({super.key, required this.banner});

  final BannerModel banner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StoreModel store = ref.watch(storeProvider);
    final int? storeId = store.id;
    final int? categoryId = banner.mainCategoryId;
    final bool isAr = context.locale.languageCode == 'ar';
    final String imageUrl =
        (isAr ? banner.imageAr : banner.imageEn) ?? banner.image ?? '';

    // Only a banner that actually leads somewhere is a tap target. Before this
    // the whole banner swallowed taps and answered nothing for any link type
    // the app doesn't handle, or for one carrying no slug at all.
    final VoidCallback? onTap = switch (banner.linkType) {
      'product' when banner.productSlug != null => () => context.pushNamed(
        AppRoutes.productDetailsScreen,
        extra: banner.productSlug,
      ),
      // This store's products in that category — the screen its category
      // chips open — not the platform-wide category (BUG-023). The banner's
      // `category_slug` is always null from the store payload anyway.
      'category' when storeId != null && categoryId != null =>
        () => context.pushNamed(
          AppRoutes.viewStoreCategoryProductsScreen,
          pathParameters: <String, String>{
            'storeId': '$storeId',
            'categoryId': '$categoryId',
          },
          extra: store.categories
              ?.where((CategoryModel c) => c.id == categoryId)
              .firstOrNull
              ?.name,
        ),
      _ => null,
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadiusGeometry.circular(16),
        ),
        child: AppCachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
        ),
      ),
    );
  }
}
