import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

class HomeBannerView extends StatelessWidget {
  const HomeBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
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
      child: const AppCachedNetworkImage(
        imageUrl:
        'https://as1.ftcdn.net/jpg/02/29/54/06/1000_F_229540688_nriN1k76uBt2lHMU9dMV2DbbXWGYPUj2.jpg',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
