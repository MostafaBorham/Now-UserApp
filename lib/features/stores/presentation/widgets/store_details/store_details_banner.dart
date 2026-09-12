import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

class StoreDetailsBanner extends StatelessWidget {
  const StoreDetailsBanner({
    super.key,
    required this.banner,
  });

  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
    final bool isAr = context.locale.languageCode == 'ar';
    final String imageUrl =
        (isAr ? banner.imageAr : banner.imageEn) ?? banner.image ?? '';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if(banner.linkType == 'product'){
          context.pushNamed(AppRoutes.productDetailsScreen,extra: banner.productSlug);
        }
        else if (banner.linkType == 'category'){
          context.pushNamed(AppRoutes.categoryDetailsScreen,extra: CategoryModel(slug: banner.categorySlug));
        }
      },
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
