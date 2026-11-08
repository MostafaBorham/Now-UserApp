import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search_result_app_bar.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search2/search_result_categories_list.dart';

class SearchResultsView extends StatelessWidget {
  const SearchResultsView({
    super.key,
    required this.searchField,
    required this.searchedTerm,
  });

  final Widget searchField;
  final String searchedTerm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchResultAppBar(searchField: searchField),
        Expanded(child: SearchResultCategoriesList(searchTerm: searchedTerm)),
      ],
    );
  }
}
