import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/best_nearby_stores_list_item.dart';








class BestNearbyStoresSection extends StatelessWidget {
  const BestNearbyStoresSection({super.key, this.title, required this.stores});





  final Map<String, dynamic>? title;
  final List<StoreModel> stores;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final String localizedTitle = context.getLocalizedApiText(title);
    final String heading = localizedTitle.isNotEmpty
        ? localizedTitle
        : LangKeys.bestNearbyStoresKey.tr();

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          AutoSizeText(
            heading,
            style: AppTextStyles.style20SemiBold.copyWith(
              color: colors.neutral1200,
            ),
          ),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: stores.length,
              separatorBuilder: (context, index) => 10.wSpace,
              itemBuilder: (context, index) {
                final StoreModel store = stores[index];
                return InkWell(


                  onTap: store.id == null
                      ? null
                      : () => context.pushNamed(
                          AppRoutes.storeDetailsScreen,
                          extra: store.id,
                        ),
                  child: BestNearbyStoresListItem(store: store),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
