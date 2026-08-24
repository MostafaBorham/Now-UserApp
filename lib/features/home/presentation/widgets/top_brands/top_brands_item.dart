import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_borders.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';

class TopBrandsItem extends StatelessWidget {
  const TopBrandsItem({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.white,
        border: AppBorders.b1(colors.neutral200),
        borderRadius: AppBorderRadius.brCircular24,
        boxShadow: [BoxShadow(
          color: colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: Offset(0, 5)
        )]
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 2.5,
                child: CachedNetworkImage(
                  imageUrl: 'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                  const SizedBox.shrink(),
                  errorWidget: (context, url, error) =>
                  const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: colors.neutral200,
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Panda',
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.black,
                      fontSize: 15,
                      height: 1.3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(context.isRTL? Icons.chevron_right : Icons.chevron_left, size: 16, color: colors.neutral500),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
