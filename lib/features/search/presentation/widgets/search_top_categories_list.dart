import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/pagination_status.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search_category_card.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search_category_card_shimmer.dart';

class SearchTopCategoriesList extends ConsumerWidget {
  const SearchTopCategoriesList({super.key});

  static const int _maxCategories = 10;
  static const int _firstPagePlaceholders = 5;

  static const double _cardAspectRatio = 0.85;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PaginationStatus<CategoryModel> status =
        PaginationStatus<CategoryModel>.from(
      ref.watch(getAppCategoriesProvider),
    );

    final double cardWidth = MediaQuery.sizeOf(context).width / 3;
    final double cardHeight = cardWidth / _cardAspectRatio;

    final Widget strip;
    if (status.firstPageError != null || status.isEmpty) {
      strip = const NoResultsWidget();
    } else if (!status.hasLoadedPage) {
      strip = _CardsStrip(
        cardWidth: cardWidth,
        itemCount: _firstPagePlaceholders,
        itemBuilder: (_, _) => const SearchCategoryCardShimmer(),
      );
    } else {
      final List<CategoryModel> categories =
          status.items.take(_maxCategories).toList();
      strip = _CardsStrip(
        cardWidth: cardWidth,
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          final CategoryModel category = categories[index];
          return SearchCategoryCard(
            category: category,
            onTap: () => context.pushNamed(
              AppRoutes.categoryDetailsScreen,
              extra: category,
            ),
          );
        },
      );
    }

    return SizedBox(height: cardHeight, child: strip);
  }
}

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
      padding: const EdgeInsets.all(2),
      itemCount: itemCount,
      separatorBuilder: (_, _) => 20.wSpace,
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
