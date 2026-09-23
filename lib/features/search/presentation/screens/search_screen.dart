import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';
import 'package:nowdelivery_user_app/core/viewmodel/recent_keywords_view_model.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search_categories_section.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search_products_grid.dart';
import 'package:nowdelivery_user_app/features/search/viewmodel/recent_search_vm.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  /// `/api/v1/products` answers every term shorter than this with an empty
  /// page, so shorter terms are not searched at all.
  static const int _minSearchLength = 3;

  String _rawQuery = '';
  String _searchedTerm = '';

  final GlobalKey _searchFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // The top-categories strip reads the kept-alive categories list, which
    // nothing retries once it has failed: re-kick it, as All Stores does.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(getAppCategoriesProvider);
      if (state.hasError && !state.hasValue) {
        ref.invalidate(getAppCategoriesProvider);
      }
    });
  }

  void _remember(String term) {
    if (term.isEmpty) return;
    ref.read(recentSearchProvider.notifier).addSearchKey(term);
  }

  void _onChanged(String value) {
    setState(() {
      _rawQuery = value;
      if (value.trim().isEmpty) _searchedTerm = '';
    });
  }

  /// Shows the results for [value], or none when it is too short to search.
  void _search(String value, {bool remember = false}) {
    final String term = value.trim();
    final bool searchable = term.length >= _minSearchLength;
    setState(() => _searchedTerm = searchable ? term : '');
    if (searchable && remember) _remember(term);
  }

  void _onSearch(String value) {
    if (!mounted) return;
    _search(value);
  }

  void _onSubmitted(String value) {
    _search(value, remember: true);
    FocusScope.of(context).unfocus();
  }

  void _onRecentSelect(String term) {
    _search(term, remember: true);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final RecentKeywordsViewModel recentVm =
        ref.read(recentSearchProvider.notifier);
    final List<String> recentSearches =
        ref.watch(recentSearchProvider).valueOrNull ?? const <String>[];

    final bool hasResults = _searchedTerm.trim().isNotEmpty;

    final Widget searchField = PrimarySearchField(
      key: _searchFieldKey,
      enableRecentKeywords: !hasResults,
      recentKeywords: _rawQuery.isEmpty ? recentSearches : const <String>[],
      onChanged: _onChanged,
      onSearch: _onSearch,
      onSubmitted: _onSubmitted,
      onRecentSelect: _onRecentSelect,
      onRecentRemove: recentVm.removeSearchKey,
      onRecentClear: recentVm.clearAll,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AppWavedView(
        appBarTitle: LangKeys.searchKey.tr(),
        canPop: context.canPop(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: <Widget>[
            if (hasResults) searchField else Flexible(child: searchField),
            if (hasResults)
              Expanded(
                // Keyed by the term so a new search starts at the top.
                child: SearchProductsGrid(
                  key: ValueKey<String>(_searchedTerm),
                  searchTerm: _searchedTerm,
                ),
              )
            else
              const SearchCategoriesSection(),
          ],
        ),
      ),
    );
  }
}
