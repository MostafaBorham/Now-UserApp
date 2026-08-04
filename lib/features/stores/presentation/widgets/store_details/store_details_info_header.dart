import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
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
    final AppColorScheme colors = context.colors;
    final store = ref.watch(storeProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context,con) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Padding(
                    padding:  EdgeInsets.only(bottom: con.maxHeight*0.13,),
                    child: AppCachedNetworkImage(
                      imageUrl: store.coverUrl ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.onPrimary,
                    ),
                    child: CircularBrandLogo(
                      radius: con.maxHeight*0.13,
                      backgroundColor: Colors.grey.shade200,
                      logoUrl: store.logoUrl ?? '',
                    ),
                  )
                ],
              );
            }
          ),
        ),
        Text(
          context.getLocalizedApiText(store.description),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.style14Regular,
        ),
        StoreInfoRow(
          infoFontSize: 15,
          infoIconSize: 20,
          deliveryTime: store.deliveryTime,
          distance: store.distance,
          deliveryFee: store.deliveryFee,
        ),
      ],
    );
  }
}
