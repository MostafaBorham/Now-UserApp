import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/pagination_scroll_listener.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/pagination_status.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search_category_card.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search_category_card_shimmer.dart';

class SearchTopCategoriesList extends ConsumerWidget {
  const SearchTopCategoriesList({
    super.key,
    required this.provider,
    required this.notifier,
  });

  final ProviderListenable<AsyncValue<PaginationModel<CategoryModel>>> provider;
  final ProviderListenable<GetAppCategoriesViewModel> notifier;

  static const int _firstPagePlaceholders = 5;
  static const int _nextPagePlaceholders = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A next-page failure never takes over the strip: report it and leave the
    // loaded cards untouched. The first-page failure is handled below instead.
    ref.listen(provider, (
      AsyncValue<PaginationModel<CategoryModel>>? previous,
      AsyncValue<PaginationModel<CategoryModel>> next,
    ) {
      if (previous?.isLoading != true) return;
      final String? error = PaginationStatus<CategoryModel>.from(next)
          .nextPageError;
      if (error != null) ErrorSnackBar.show(context, error);
    });

    final PaginationStatus<CategoryModel> status =
        PaginationStatus<CategoryModel>.from(ref.watch(provider));

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double cardWidth = constraints.maxWidth * 0.3;

        // Nothing loaded and the first page failed, or it came back empty:
        // one no-results state for both (req 10).
        if (status.firstPageError != null || status.isEmpty) {
          return const NoResultsWidget();
        }

        // First page still loading: a strip of shimmer cards (req 10).
        if (!status.hasLoadedPage) {
          return _CardsStrip(
            cardWidth: cardWidth,
            itemCount: _firstPagePlaceholders,
            itemBuilder: (_, _) => const AppShimmer(
              child: SearchCategoryCardShimmer(),
            ),
          );
        }

        final int trailing =
            status.isNextPageLoading ? _nextPagePlaceholders : 0;

        return PaginationScrollListener(
          canLoadNextPage: status.canRequestNextPage,
          onLoadNextPage: ref.read(notifier).loadNextPage,
          child: _CardsStrip(
            cardWidth: cardWidth,
            itemCount: status.items.length + trailing,
            itemBuilder: (BuildContext context, int index) {
              if (index >= status.items.length) {
                return const AppShimmer(child: SearchCategoryCardShimmer());
              }
              final CategoryModel category = status.items[index];
              return SearchCategoryCard(
                category: category,
                onTap: () => context.pushNamed(
                  AppRoutes.categoryDetailsScreen,
                  extra: category,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// The horizontal, fixed-width-card list shared by every state so the shimmer
/// strip and the loaded strip line up cell for cell.
class _CardsStrip extends StatelessWidget {
  const _CardsStrip({
    required this.cardWidth,
    required this.itemCount,
    required this.itemBuilder,
  });

  final double cardWidth;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(2),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(width: 10),
      itemBuilder: (BuildContext context, int index) => SizedBox(
        width: cardWidth,
        child: itemBuilder(context, index),
      ),
    );
  }
}
