import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/providers/favourites_filter_provider.dart';

/// The chrome shared by both favourites tabs: a search field over an app-category
/// [CustomButtonTabBar], with one paginated list per category tab below. It owns
/// no filter state itself — the search text and selected category live in
/// [favouritesFilterProvider] keyed by [type], so every category view reacts to
/// a single change. [listBuilder] builds the paginated list for a given category
/// (`null` = the "All" tab), keeping this widget type-agnostic across products
/// and stores.
class FavouritesTabView extends ConsumerWidget {
  const FavouritesTabView({
    super.key,
    required this.type,
    required this.listBuilder,
  });

  /// API discriminator of the tab — `product` / `vendor`. Also the
  /// [favouritesFilterProvider] family key.
  final String type;

  /// Builds the paginated list for a tab. `null` is the "All" tab.
  final Widget Function(CategoryModel? category) listBuilder;

  /// The [CategoryModel] behind a tab index over `[All, ...categories]`
  /// (index 0 = All = null).
  CategoryModel? _categoryAt(int index, List<CategoryModel> categories) =>
      index > 0 && index - 1 < categories.length ? categories[index - 1] : null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final AsyncValue<PaginationModel<CategoryModel>> categoriesState =
        ref.watch(getAppCategoriesProvider);
    final FavouritesFilter filter = ref.watch(favouritesFilterProvider(type));

    final List<CategoryModel> categories =
        categoriesState.valueOrNull?.data ?? const <CategoryModel>[];

    // The tab index behind the currently selected category (0 = "All"). `-1`
    // (not found) falls back to "All".
    final int selectedIndex = filter.category == null
        ? 0
        : categories.indexOf(filter.category!) + 1;

    // Tabs and views are always the same length: index 0 = "All", then one
    // entry per loaded category. While categories load, only "All" exists; the
    // tab count grows once they arrive, so the tab bar is keyed by that count to
    // rebuild its internally-owned TabController to the matching length.
    final List<String> tabs = <String>[
      LangKeys.allKey.tr(),
      ...categories.map(
        (CategoryModel category) => context.getLocalizedApiText(category.name),
      ),
    ];

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
          child: CustomButtonTabBar(
            // Rebuild (and re-size the TabController) when the tab count changes
            // — e.g. once categories finish loading.
            key: ValueKey<int>(tabs.length),
            selectedIndex: selectedIndex,
            tabs: tabs,
            views: <Widget>[
              listBuilder(null),
              ...categories.map(
                (CategoryModel category) => listBuilder(category),
              ),
            ],
            onTap: (int index) => ref
                .read(favouritesFilterProvider(type).notifier)
                .setCategory(_categoryAt(index, categories)),
            unSelectedTabColor: colors.neutral500.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}
