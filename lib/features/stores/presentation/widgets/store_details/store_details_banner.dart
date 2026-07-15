import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/banner_model.dart';

class StoreDetailsBanner extends StatelessWidget {
  const StoreDetailsBanner({
    super.key,
    required this.banner,
  });

  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadiusGeometry.circular(16),
      ),
      child: AppCachedNetworkImage(
        imageUrl: banner.image ?? '',
        width: double.infinity,
      ),
    );
  }
}
