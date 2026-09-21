import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';
import 'package:nowdelivery_user_app/core/viewmodel/recent_keywords_view_model.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search_categories_section.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search_products_grid.dart';
import 'package:nowdelivery_user_app/features/search/viewmodel/recent_search_vm.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _rawQuery = '';
  String _searchedTerm = '';

  final GlobalKey _searchFieldKey = GlobalKey();

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

  void _onSearch(String value) {
    if (!mounted) return;
    final String term = value.trim();
    if (term.isEmpty) return;
    setState(() => _searchedTerm = term);
  }

  void _onSubmitted(String value) {
    final String term = value.trim();
    if (term.isEmpty) return;
    setState(() => _searchedTerm = term);
    _remember(term);
    FocusScope.of(context).unfocus();
  }

  void _onRecentSelect(String term) {
    setState(() => _searchedTerm = term);
    _remember(term);
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
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SearchProductsGrid(searchTerm: _searchedTerm),
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
