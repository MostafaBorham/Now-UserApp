import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/best_nearby_stores_list_item.dart';

import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class BestNearbyStoresSection extends StatelessWidget {
  const BestNearbyStoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          AutoSizeText(LangKeys.topNearbyStoresKey.tr(),style: AppTextStyles.style20SemiBold.copyWith(
              color: colors.onTertiaryFixed
          ),),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return InkWell(
                     onTap: () => context.pushNamed(AppRoutes.storeDetailsScreen),
                    child: BestNearbyStoresListItem());
              },
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) {
                return 10.wSpace;
              },
              itemCount: 5,
            ),
          ),
        ],
      ),
    );
  }
}
