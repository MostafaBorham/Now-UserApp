import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/top_wave_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';

import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_info_row.dart';
class StoreDetailsInfoHeader extends StatelessWidget {
  const StoreDetailsInfoHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ClipPath(
                clipper: TopWaveClipper(),
                child: AppCachedNetworkImage(
                  imageUrl:
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSTE97wzpAcXRQWUFbg6JGvWivxBLHnzFq2p9DVZRMKZg&s=10',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Container(color: colors.onPrimary, height: 80),
          ],
        ),
        Align(
          alignment: AlignmentDirectional.bottomCenter,
          child: Column(
            spacing: 5,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.onPrimary,
                ),
                child: CircularBrandLogo(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  logoUrl:
                  'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                ),
              ),
              Text(
                'I am a store that sells food products and all basic necessities',
                style: AppTextStyles.style14Regular,
              ),
              StoreInfoRow(infoFontSize: 15, infoIconSize: 20),
            ],
          ),
        ),
      ],
    );
  }
}