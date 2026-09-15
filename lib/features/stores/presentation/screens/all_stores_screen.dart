import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/app_filter_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_stores_vm.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/all_stores/stores_search_filter_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/all_stores/stores_filter_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/all_stores/stores_list_view.dart';

class AllStoresScreen extends ConsumerStatefulWidget {
  const AllStoresScreen({super.key});

  @override
  ConsumerState<AllStoresScreen> createState() => _AllStoresScreenState();
}

class _AllStoresScreenState extends ConsumerState<AllStoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(getAppCategoriesProvider);
      if (state.hasError && !state.hasValue) {
        ref.invalidate(getAppCategoriesProvider);
      }
    });
  }

  CategoryModel? _categoryAt(int index, List<CategoryModel> categories) =>
      index > 0 && index - 1 < categories.length ? categories[index - 1] : null;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final AsyncValue<PaginationModel<CategoryModel>> categoriesState = ref
        .watch(getAppCategoriesProvider);

    final StoresSearchFilter filter = ref.watch(storesSearchFilterProvider);

    final List<CategoryModel> categories =
        categoriesState.valueOrNull?.data ?? const <CategoryModel>[];

    final int selectedIndex = filter.category == null
        ? 0
        : categories.indexOf(filter.category!) + 1;

    final List<String> tabs = [
      LangKeys.allKey.tr(),
      ...categories.map((c) => context.getLocalizedApiText(c.name)),
    ];

    return Scaffold(
      body: AppWavedView(
        body: Column(
          spacing: 16,
          children: [
            PrimarySearchField(
              isAnimated: false,
              onSearch: (query) =>
                  ref.read(storesSearchFilterProvider.notifier).setSearch(query),
            ),
            Expanded(
              child: CustomButtonTabBar(
                key: ValueKey<int>(tabs.length),
                selectedIndex: selectedIndex,
                filterWidget: AppFilterIcon(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => StoresFilterView(
                      onApply: (type, rating, categoryIndex) {
                        final int index = categoryIndex ?? 0;
                        ref
                            .read(storesSearchFilterProvider.notifier)
                            .applyFilter(
                              category: _categoryAt(index, categories),
                              rating: rating ?? '',
                            );
                      },
                    ),
                  ),
                ),
                onTap: (index) {
                  final CategoryModel? category =
                      _categoryAt(index, categories);
                  if (category != null) {
                    ref.invalidate(
                      getCategoryStoresProvider((
                        categorySlug: category.slug ?? '',
                        categoryId: null,
                        searchKey: filter.search.isEmpty ? null : filter.search,
                      )),
                    );
                  }
                  ref
                      .read(storesSearchFilterProvider.notifier)
                      .setCategory(category);
                },
                tabs: tabs,
                views: [
                  const StoresListView(),
                  ...categories.map(
                    (category) => StoresListView(category: category),
                  ),
                ],
                unSelectedTabColor: colors.neutral500.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
        appBarTitle: LangKeys.allStoresKey.tr(),
        canPop: context.canPop(),
      ),
    );
  }
}
