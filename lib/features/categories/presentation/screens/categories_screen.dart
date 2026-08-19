import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/categories/category_card.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/categories/category_card_shimmer.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';

/// The app categories as an infinite-scrolling grid.
///
/// Only describes *what* the grid shows — the paging behaviour (next page on
/// scroll, pull-to-refresh, loading, empty and error states) lives in
/// [PaginatedView] and [GetAppCategoriesViewModel].
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  static const SliverGridDelegateWithFixedCrossAxisCount _gridDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        mainAxisExtent: 220,
      );

  @override
  void initState() {
    super.initState();
    // The categories are preloaded on splash and reused here. Fetch only if
    // that never happened or failed (no value yet) — already-loaded data is
    // kept as-is (no refetch) — so opening this while errored flips it to
    // loading and the shimmer grid shows first.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || ref.read(getAppCategoriesProvider).hasValue) return;
      ref.read(getAppCategoriesProvider.notifier).loadFirstPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final GetAppCategoriesViewModel categoriesViewModel = ref.read(
      getAppCategoriesProvider.notifier,
    );

    return Scaffold(
      body: AppWavedView(
        appBarTitle: LangKeys.categoriesTitleKey.tr(),
        canPop: context.canPop(),
        body: SafeArea(
          child: PaginatedView<CategoryModel>(
            provider: getAppCategoriesProvider,
            onRefresh: categoriesViewModel.loadFirstPage,
            onLoadNextPage: categoriesViewModel.loadNextPage,
            layout: const PaginatedGridLayout(gridDelegate: _gridDelegate),
            firstPagePlaceholdersCount: 8,
            // Fills the grid while the first page loads and trails it while the
            // next one does, so the skeleton always matches the real cards.
            placeholderBuilder: (BuildContext context) =>
                const AppShimmer(child: CategoryCardShimmer()),
            itemBuilder:
                (BuildContext context, CategoryModel category, int index) =>
                    CategoryCard(
                      category: category,
                      onTap: () => context.pushNamed(
                        AppRoutes.categoryDetailsScreen,
                        extra: category,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
