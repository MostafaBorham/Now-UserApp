import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';






class HomeBannerView extends StatelessWidget {
  const HomeBannerView({super.key, this.banner});

  final BannerModel? banner;

  static const String _placeholderImage =
      'https://as1.ftcdn.net/jpg/02/29/54/06/1000_F_229540688_nriN1k76uBt2lHMU9dMV2DbbXWGYPUj2.jpg';

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isAr = context.locale.languageCode == 'ar';
    final String imageUrl =
        (isAr ? banner?.imageAr : banner?.imageEn) ??
        banner?.image ??
        _placeholderImage;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTap(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.black.withValues(alpha: 0.25),
              offset: Offset.zero,
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: AppCachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {




    if (banner?.productSlug != null) {
      context.pushNamed(
        AppRoutes.productDetailsScreen,
        extra: banner!.productSlug,
      );
    }
  }
}
