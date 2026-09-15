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








class FavouritesTabView extends ConsumerWidget {
  const FavouritesTabView({
    super.key,
    required this.type,
    required this.listBuilder,
  });



  final String type;


  final Widget Function(CategoryModel? category) listBuilder;



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



    final int selectedIndex = filter.category == null
        ? 0
        : categories.indexOf(filter.category!) + 1;





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
