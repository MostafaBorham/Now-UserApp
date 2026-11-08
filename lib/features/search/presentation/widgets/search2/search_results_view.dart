import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search_result_app_bar.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search_result_list.dart';

class SearchResultsView extends StatelessWidget {
  const SearchResultsView({
    super.key,
    required this.searchField,
    required this.searchedTerm,
    required this.onBack,
  });

  final Widget searchField;
  final String searchedTerm;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchResultAppBar(searchField: searchField, onBack: onBack),
        if (searchedTerm.isNotEmpty)
          Expanded(
            child: SearchResultList(
              key: ValueKey(searchedTerm),
              searchTerm: searchedTerm,
            ),
          ),
      ],
    );
  }
}
