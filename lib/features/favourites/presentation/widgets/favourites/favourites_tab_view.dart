import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/features/favourites/data/models/favourite_category_model.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/providers/favourites_filter_provider.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/favourite_categories_vm.dart';

/// The chrome shared by both favourites tabs: a search field over a category
/// [CustomButtonTabBar], with one paginated list per category tab below. It owns
/// no filter state itself — the search text and selected category live in
/// [favouritesFilterProvider] keyed by [type], so every category view reacts to
/// a single change. [listBuilder] builds the paginated list for a given category
/// id (`null` = the "All" tab), keeping this widget type-agnostic across products
/// and stores.
///
/// The category chips come from [favouriteCategoriesProvider] — only the
/// categories the caller actually has favourites in — so a tab never opens onto
/// an "empty favourites" state for a category the user never favourited in.
class FavouritesTabView extends ConsumerWidget {
  const FavouritesTabView({
    super.key,
    required this.type,
    required this.listBuilder,
  });

  /// API discriminator of the tab — `product` / `vendor`. Also the
  /// [favouritesFilterProvider] and [favouriteCategoriesProvider] family key.
  final String type;

  /// Builds the paginated list for a tab. `null` is the "All" tab.
  final Widget Function(int? categoryId) listBuilder;

  /// The category id behind a tab index over `[All, ...categories]`
  /// (index 0 = All = null).
  int? _categoryIdAt(int index, List<FavouriteCategoryModel> categories) =>
      index > 0 && index - 1 < categories.length
          ? categories[index - 1].id
          : null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final AsyncValue<List<FavouriteCategoryModel>> categoriesState =
        ref.watch(favouriteCategoriesProvider(type));
    final FavouritesFilter filter = ref.watch(favouritesFilterProvider(type));

    // When the chips refresh after an unfavourite and the currently-selected
    // category is gone (its last favourite was removed), reset the filter to
    // "All" so the fallen-back tab actually loads instead of showing a shimmer
    // for a category id that no longer exists.
    ref.listen<AsyncValue<List<FavouriteCategoryModel>>>(
      favouriteCategoriesProvider(type),
      (_, AsyncValue<List<FavouriteCategoryModel>> next) {
        final List<FavouriteCategoryModel>? categories = next.valueOrNull;
        if (categories == null) return;
        final int? selected = ref.read(favouritesFilterProvider(type)).categoryId;
        if (selected != null &&
            !categories.any((FavouriteCategoryModel c) => c.id == selected)) {
          ref.read(favouritesFilterProvider(type).notifier).setCategory(null);
        }
      },
    );

    final List<FavouriteCategoryModel> categories =
        categoriesState.valueOrNull ?? const <FavouriteCategoryModel>[];

    // The tab index behind the currently selected category (0 = "All"). A
    // category that is no longer in the list (`indexWhere` → -1) falls back to
    // "All".
    final int selectedIndex = filter.categoryId == null
        ? 0
        : categories.indexWhere(
              (FavouriteCategoryModel category) =>
                  category.id == filter.categoryId,
            ) +
            1;

    // Tabs and views are always the same length: index 0 = "All", then one
    // entry per loaded category. While categories load, only "All" exists; the
    // tab count grows once they arrive, so the tab bar is keyed by that count to
    // rebuild its internally-owned TabController to the matching length.
    final List<String> tabs = <String>[
      LangKeys.allKey.tr(),
      ...categories.map(
        (FavouriteCategoryModel category) =>
            context.getLocalizedApiText(category.name),
      ),
    ];

    // No favourites in any category: a lone "All" chip over the empty state is
    // noise, so the list shows without the tab bar. Only once the categories
    // have loaded, so users with favourites don't see the bar pop in.
    final bool hideTabs = categoriesState.hasValue && categories.isEmpty;

    return Column(
      spacing: 16,
      children: <Widget>[
        PrimarySearchField(
          isAnimated: false,
          onSearch: (String query) => ref
              .read(favouritesFilterProvider(type).notifier)
              .setSearch(query),
        ),
        Expanded(
          child: hideTabs ? listBuilder(null) : CustomButtonTabBar(
            // Rebuild (and re-size the TabController) when the tab count changes
            // — e.g. once categories finish loading.
            key: ValueKey<int>(tabs.length),
            selectedIndex: selectedIndex,
            tabs: tabs,
            views: <Widget>[
              listBuilder(null),
              ...categories.map(
                (FavouriteCategoryModel category) => listBuilder(category.id),
              ),
            ],
            onTap: (int index) => ref
                .read(favouritesFilterProvider(type).notifier)
                .setCategory(_categoryIdAt(index, categories)),
            unSelectedTabColor: colors.neutral500.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}
