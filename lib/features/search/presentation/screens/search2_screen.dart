import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search_placeholder_view.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search_results_view.dart';

class Search2Screen extends StatefulWidget {
  const Search2Screen({super.key});

  @override
  State<Search2Screen> createState() => _Search2ScreenState();
}

class _Search2ScreenState extends State<Search2Screen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _searchFieldKey = GlobalKey();
  bool _showResults = false;
  String _searchedTerm = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChange);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChange() {
    final String term = _searchController.text.trim();
    final bool showResults = term.isNotEmpty;
    if (showResults == _showResults) return;
    setState(() {
      _showResults = showResults;
      if (showResults) _searchedTerm = term;
    });
  }

  void _onSearch(String value) {
    final String term = value.trim();
    if (!_showResults ||
        term != _searchController.text.trim() ||
        term == _searchedTerm) {
      return;
    }
    setState(() => _searchedTerm = term);
  }

  void _onMostSearchedSelect(String tag) {
    _searchController.value = TextEditingValue(
      text: tag,
      selection: TextSelection.collapsed(offset: tag.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget searchField = PrimarySearchField(
      key: _searchFieldKey,
      controller: _searchController,
      textDirection: _showResults && context.locale.languageCode == 'ar'
          ? TextDirection.rtl
          : null,
      onSearch: _onSearch,
      onSubmitted: _onSearch,
    );
    return Scaffold(
      backgroundColor: context.colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        // Move the live field between headers while the incoming view animates.
        layoutBuilder: (current, _) => current ?? const SizedBox.shrink(),
        transitionBuilder: (Widget child, Animation<double> animation) =>
            FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.02),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
        child: _showResults
            ? SearchResultsView(
                searchField: searchField,
                searchedTerm: _searchedTerm,
              )
            : SearchPlaceholderView(
                searchField: searchField,
                onMostSearchedSelect: _onMostSearchedSelect,
              ),
      ),
    );
  }
}
