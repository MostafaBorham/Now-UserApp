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
  static const int _minSearchLength = 3;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _searchFieldKey = GlobalKey();
  String _searchedTerm = '';
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    if (_searchFocusNode.hasFocus && !_showResults) {
      setState(() => _showResults = true);
    }
  }

  void _backToLanding() {
    _searchFocusNode.unfocus();
    _searchController.clear();
    setState(() {
      _showResults = false;
      _searchedTerm = '';
    });
  }

  void _onChanged(String value) {
    if (value.trim().isEmpty) _onSearch(value);
  }

  void _onSearch(String value) {
    final String term = value.trim();
    if (term != _searchController.text.trim()) return;
    final String nextTerm = term.length >= _minSearchLength ? term : '';
    if (nextTerm == _searchedTerm) return;
    setState(() {
      _searchedTerm = nextTerm;
      if (nextTerm.isNotEmpty) _showResults = true;
    });
  }

  void _onMostSearchedSelect(String tag) {
    _searchController.value = TextEditingValue(
      text: tag,
      selection: TextSelection.collapsed(offset: tag.length),
    );
    _onSearch(tag);
  }

  @override
  Widget build(BuildContext context) {
    final Widget searchField = PrimarySearchField(
      key: _searchFieldKey,
      controller: _searchController,
      focusNode: _searchFocusNode,
      textDirection: _showResults && context.locale.languageCode == 'ar'
          ? TextDirection.rtl
          : null,
      onChanged: _onChanged,
      onSearch: _onSearch,
      onSubmitted: _onSearch,
    );
    final Widget scaffold = Scaffold(
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
                onBack: _backToLanding,
              )
            : SearchPlaceholderView(
                searchField: searchField,
                onMostSearchedSelect: _onMostSearchedSelect,
              ),
      ),
    );
    return PopScope<Object?>(
      canPop: !_showResults,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _showResults) _backToLanding();
      },
      child: scaffold,
    );
  }
}
