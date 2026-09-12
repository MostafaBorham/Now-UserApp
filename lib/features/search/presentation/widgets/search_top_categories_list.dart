import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/pagination_scroll_listener.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/pagination_status.dart';
import 'package:nowdelivery_user_app/features/search/viewmodel/get_search_categories_vm.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search_category_card.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search_category_card_shimmer.dart';

class SearchTopCategoriesList extends ConsumerWidget {
  const SearchTopCategoriesList({
    super.key,
    required this.provider,
    required this.notifier,
  });

  final ProviderListenable<AsyncValue<PaginationModel<CategoryModel>>> provider;
  final ProviderListenable<SearchCategoriesViewModel> notifier;

  static const int _firstPagePlaceholders = 5;
  static const int _nextPagePlaceholders = 2;

  /// Every card's width ÷ height. The strip is laid out at the card height so a
  /// horizontal [AspectRatio] resolves each cell back to a third of the screen.
  static const double _cardAspectRatio = 0.85;

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
      if (error != null) AppToast.showError(context, error);
    });

    final PaginationStatus<CategoryModel> status =
        PaginationStatus<CategoryModel>.from(ref.watch(provider));

    // A third of the screen wide at [_cardAspectRatio]; the strip is exactly
    // that tall so the per-cell [AspectRatio] resolves each width back to that
    // third. The card and its shimmer share the cell, so they always match.
    final double cardWidth = MediaQuery.sizeOf(context).width / 3;
    final double cardHeight = cardWidth / _cardAspectRatio;

    final Widget strip;
    // Nothing loaded and the first page failed, or it came back empty: one
    // no-results state for both (req 10).
    if (status.firstPageError != null || status.isEmpty) {
      strip = const NoResultsWidget();
    } else if (!status.hasLoadedPage) {
      // First page still loading: a strip of shimmer cards (req 10).
      strip = _CardsStrip(
        cardWidth: cardWidth,
        itemCount: _firstPagePlaceholders,
        itemBuilder: (_, _) => SearchCategoryCardShimmer(),
      );
    } else {
      final int trailing = status.isNextPageLoading ? _nextPagePlaceholders : 0;
      strip = PaginationScrollListener(
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
    }

    return SizedBox(height: cardHeight, child: strip);
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
      // Horizontal-only padding: the cell keeps the strip's full height, so the
      // AspectRatio holds and the width stays a third of the screen.
      padding: const EdgeInsets.all(2),
      itemCount: itemCount,
      separatorBuilder: (_, _) => 20.wSpace,
      // Fix the width to a third of the screen, then let AspectRatio derive the
      // height from it — the card and its shimmer are both sized this way.
      itemBuilder: (BuildContext context, int index) => SizedBox(
        width: cardWidth,
        child: AspectRatio(
          aspectRatio: SearchTopCategoriesList._cardAspectRatio,
          child: itemBuilder(context, index),
        ),
      ),
    );
  }
}
