import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

class StoreDetailsBanner extends StatelessWidget {
  const StoreDetailsBanner({super.key, required this.banner});

  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
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
      'category' when banner.categorySlug != null => () => context.pushNamed(
        AppRoutes.categoryDetailsScreen,
        extra: CategoryModel(slug: banner.categorySlug),
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
