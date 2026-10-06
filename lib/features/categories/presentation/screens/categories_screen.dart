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
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
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
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 190,
      );

  final ScrollController _scrollController = ScrollController();

  /// False until the refresh below is sent (the frame after the first).
  bool _refreshSent = false;

  @override
  void initState() {
    super.initState();
    // The categories are preloaded on the splash and kept alive, so the list
    // could be stale or cut short until a manual pull (BUG-020, QA V2). Every
    // open refreshes it: a loaded list stays on screen while page one reloads,
    // a failed or missing one loads afresh behind the shimmer, and a load
    // already on its way is left alone.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _refreshSent = true);
      ref.read(getAppCategoriesProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        scrollController: _scrollController,
        body: SafeArea(
          child: PaginatedView<CategoryModel>(
            // Until the refresh goes out, a failure left over from the splash
            // reads as loading: the first frame showed that stale error page.
            provider: _refreshSent
                ? getAppCategoriesProvider
                : getAppCategoriesProvider.select(
                    (AsyncValue<PaginationModel<CategoryModel>> s) =>
                        s.hasError && !s.hasValue
                        ? const AsyncValue<
                            PaginationModel<CategoryModel>
                          >.loading()
                        : s,
                  ),
            onRefresh: categoriesViewModel.loadFirstPage,
            onLoadNextPage: categoriesViewModel.loadNextPage,
            scrollController: _scrollController,
            layout: const PaginatedGridLayout(
              gridDelegate: _gridDelegate,
              padding: EdgeInsets.only(top: 57),
            ),
            firstPagePlaceholdersCount: 9,
            // Fills the grid while the first page loads and trails it while the
            // next one does, so the skeleton always matches the real cards.
            placeholderBuilder: (BuildContext context) =>
                const AppShimmer(child: CategoryCardShimmer()),
            itemBuilder:
                (BuildContext context, CategoryModel category, int index) =>
                    CategoryCard(
                      category: category,
                      onTap: category.slug == null
                          ? null
                          : () => context.pushNamed(
                              AppRoutes.categoryDetailsScreen,
                              pathParameters: <String, String>{
                                'slug': category.slug!,
                              },
                              extra: category.name,
                            ),
                    ),
          ),
        ),
      ),
    );
  }
}
