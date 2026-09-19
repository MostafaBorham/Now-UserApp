import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/best_nearby_stores_list_item.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';

/// The `nearby_stores` section: a horizontal list of the stores closest to the
/// customer, each card tappable through to its store details.
///
/// The feed decides what "nearby" means — for a guest it measures from the
/// device coordinates the Home tab sends, and for a logged-in user from the
/// address on their profile (see `HomeView._loadFeed`). This widget only
/// renders whatever order it is handed.
class BestNearbyStoresSection extends ConsumerWidget {
  const BestNearbyStoresSection({super.key, this.title, required this.stores});

  /// Section title as the feed's `{ar, en}` map — the backend owns section
  /// headings, so whatever it returns for the current locale is displayed
  /// as-is. The app's own label stands in only when the admin left the title
  /// empty, never to override a title that was sent.
  final Map<String, dynamic>? title;
  final List<StoreModel> stores;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  // A store arriving without an id can't be opened; its card
                  // still renders, it just doesn't navigate.
                  onTap: store.id == null
                      ? null
                      : () => context.pushNamed(
                          AppRoutes.storeDetailsScreen,
                          extra: store.id,
                        ),
                  child: BestNearbyStoresListItem(
                    store: store,
                    onFavouriteChanged: (bool isFavourite) => ref
                        .read(getHomeSectionsProvider.notifier)
                        .updateStoreFavourite(store.id, isFavourite),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
