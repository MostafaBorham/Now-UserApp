import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/search/data/last_search_results_cache.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search2_app_bar.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search2_banners_slider.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search2_most_searched_section.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search2_recent_search_section.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search2_top_brands_section.dart';

class SearchPlaceholderView extends ConsumerWidget {
  const SearchPlaceholderView({
    super.key,
    required this.searchField,
    required this.onMostSearchedSelect,
  });

  final Widget searchField;
  final ValueChanged<String> onMostSearchedSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cached = ref.watch(lastSearchResultsProvider);
    final results = cached.valueOrNull;
    final bool showShimmer = cached.isLoading && results == null;
    final bool hasResults = results?.isNotEmpty == true;

    return Column(
      children: [
        Search2AppBar(searchField: searchField),
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              top: 16,
              bottom: MediaQuery.paddingOf(context).bottom + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                if (showShimmer || hasResults)
                  Search2RecentSearchSection(
                    cards: results ?? const [],
                    isLoading: showShimmer,
                  ),
                Search2MostSearchedSection(onSelect: onMostSearchedSelect),
                const Search2TopBrandsSection(),
                const Search2BannersSlider(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
