import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_borders.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class TopBrandsItem extends StatelessWidget {
  const TopBrandsItem({super.key, this.store});

  /// Null in the loading (shimmer) state — the item then paints neutral
  /// placeholder blocks for AppShimmer to run over.
  final StoreModel? store;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final StoreModel? store = this.store;
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
                child: _logo(colors, store),
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
                  child: store == null
                      ? Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: colors.neutral500,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        )
                      : Text(
                          context.getLocalizedApiText(store.name),
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

  Widget _logo(AppColorScheme colors, StoreModel? store) {
    if (store == null) {
      return Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.neutral500,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }
    // No approved logo → the "failed to load image" placeholder, not a blank.
    return AppCachedNetworkImage(
      imageUrl: store.logoUrl ?? '',
      fit: BoxFit.contain,
    );
  }
}
