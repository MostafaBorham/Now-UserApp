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
import 'package:nowdelivery_user_app/features/stores/presentation/providers/all_stores/stores_search_filter_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/all_stores/stores_filter_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/all_stores/stores_list_view.dart';

class AllStoresScreen extends ConsumerStatefulWidget {
  const AllStoresScreen({super.key});

  @override
  ConsumerState<AllStoresScreen> createState() => _AllStoresScreenState();
}

class _AllStoresScreenState extends ConsumerState<AllStoresScreen> {
  int selectedTabIndex = 0;

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

  /// The [CategoryModel] behind a tab index over `[All, ...categories]`
  /// (index 0 = All = null).
  CategoryModel? _categoryAt(int index, List<CategoryModel> categories) =>
      index > 0 && index - 1 < categories.length ? categories[index - 1] : null;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final AsyncValue<PaginationModel<CategoryModel>> categoriesState = ref
        .watch(getAppCategoriesProvider);

    // Keep the screen's search/filter state alive for as long as the screen is
    // on-screen (it auto-disposes when we leave).
    ref.watch(storesSearchFilterProvider);

    final bool isLoading =
        categoriesState.isLoading && !categoriesState.hasValue;

    final List<CategoryModel> categories =
        categoriesState.valueOrNull?.data ?? const <CategoryModel>[];

    final List<String?> tabs = [LangKeys.allKey.tr()];
    if (isLoading) {
      tabs.addAll(List.filled(4, null));
    } else {
      tabs.addAll(categories.map((c) => context.getLocalizedApiText(c.name)));
    }

    return Scaffold(
      body: AppWavedView(
        body: Column(
          spacing: 16,
          children: [
            PrimarySearchField(
              suggestions: [LangKeys.searchForAStoreKey.tr()],
              // (3) Search field used → update the provider's search text.
              onSearch: (query) =>
                  ref.read(storesSearchFilterProvider.notifier).setSearch(query),
            ),
            Expanded(
              child: CustomButtonTabBar(
                isSaveState: false,
                filterWidget: AppFilterIcon(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => StoresFilterView(
                      // (2) Returned from the filter → update category + rating,
                      // and move the tab bar to the picked category.
                      onApply: (type, rating, categoryIndex) {
                        final int index = categoryIndex ?? 0;
                        ref
                            .read(storesSearchFilterProvider.notifier)
                            .applyFilter(
                              category: _categoryAt(index, categories),
                              rating: rating ?? '',
                            );
                        setState(() => selectedTabIndex = index);
                      },
                    ),
                  ),
                ),
                selectedIndex: selectedTabIndex,
                // (1) Category tab changed → update the provider's category.
                onTap: (index) {
                  ref
                      .read(storesSearchFilterProvider.notifier)
                      .setCategory(_categoryAt(index, categories));
                  setState(() => selectedTabIndex = index);
                },
                tabs: tabs,
                views: [
                  const StoresListView(),
                  if (!isLoading)
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
