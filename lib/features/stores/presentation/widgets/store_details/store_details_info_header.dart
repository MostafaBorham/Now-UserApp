import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_info_row.dart';

class StoreDetailsInfoHeader extends ConsumerWidget {
  const StoreDetailsInfoHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final store = ref.watch(storeProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, con) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // The logo (64 across, 4px white ring) straddles the cover's
                  // bottom edge, so the cover stops half a logo short.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: AppCachedNetworkImage(
                      imageUrl: store.coverUrl ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.white,
                    ),
                    child: CircularBrandLogo(
                      radius: 28,
                      logoScale: 1.9,
                      logoUrl: store.logoUrl ?? '',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Text(
          context.getLocalizedApiText(store.description),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.style14Regular.copyWith(
            color: colors.neutral500,
          ),
        ),
        StoreInfoRow(
          infoFontSize: 14,
          infoIconSize: 16,
          deliveryTime: store.deliveryTime,
          distance: store.distance?.toString(),
          deliveryFee: store.deliveryFee?.toString(),
        ),
      ],
    );
  }
}
