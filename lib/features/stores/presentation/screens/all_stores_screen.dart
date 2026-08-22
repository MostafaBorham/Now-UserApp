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

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final AsyncValue<PaginationModel<CategoryModel>> categoriesState =
        ref.watch(getAppCategoriesProvider);

    final bool isLoading =
        categoriesState.isLoading && !categoriesState.hasValue;

    final List<String?> tabs = [LangKeys.allKey.tr()];

    if (isLoading) {
      tabs.addAll(List.filled(4, null));
    } else {
      categoriesState.whenData((page) {
        tabs.addAll(
          page.data.map((c) => context.getLocalizedApiText(c.name)),
        );
      });
    }

    return Scaffold(
      body: AppWavedView(
        body: Column(
          spacing: 16,
          children: [
            PrimarySearchField(
              suggestions: [LangKeys.searchForAStoreKey.tr()],
              onSearch: (query) {
                // TODO: filter stores by query
              },
            ),
            Expanded(
              child: CustomButtonTabBar(
                filterWidget: AppFilterIcon(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => StoresFilterView(
                      onApply: (type, rating, categoryIndex) {
                        if (categoryIndex != null) {
                          setState(() => selectedTabIndex = categoryIndex);
                        }
                      },
                    ),
                  ),
                ),
                selectedIndex: selectedTabIndex,
                onTap: (index) => setState(() => selectedTabIndex = index),
                tabs: tabs,
                views: [
                  StoresListView(),
                  if (!isLoading)
                    ...List.generate(
                      tabs.length - 1,
                      (_) => StoresListView(),
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
