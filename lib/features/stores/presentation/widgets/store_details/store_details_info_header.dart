import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/top_wave_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/store_details/store_model_provider.dart';

import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_info_row.dart';
class StoreDetailsInfoHeader extends ConsumerWidget {
  const StoreDetailsInfoHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final store = ref.watch(storeProvider);
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: AppCachedNetworkImage(
                imageUrl: store.coverUrl ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR4_GqEfEcKqt8SxRJ5dE-st_feAKWGY2ZufZWIck2wdA&s',
                fit: BoxFit.cover,
                width: double.infinity,
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
                  logoUrl: store.logoUrl ?? 'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                ),
              ),
              Text(
                store.description ?? 'I am a store that sells food products and all basic',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.style14Regular,
              ),
              StoreInfoRow(
                infoFontSize: 15,
                infoIconSize: 20,
                deliveryTime: store.deliveryTime??20,
                distance: store.distance??50,
                deliveryFee: store.deliveryFee??10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
