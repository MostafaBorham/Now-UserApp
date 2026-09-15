import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/pagination_status.dart';
import 'package:nowdelivery_user_app/core/viewmodel/recent_keywords_view_model.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search_top_categories_list.dart';
import 'package:nowdelivery_user_app/features/search/viewmodel/get_search_categories_vm.dart';
import 'package:nowdelivery_user_app/features/search/viewmodel/recent_search_vm.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _rawQuery = '';

  bool _wasShimmering = false;

  void _remember(String term) {
    if (term.isEmpty) return;
    ref.read(recentSearchProvider.notifier).addSearchKey(term);
  }

  void _onSearch(String value) {
    if (!mounted) return;
    final String term = value.trim();
    ref.read(searchCategoriesProvider.notifier).search(term);
    _remember(term);
  }

  void _onSubmitted(String value) {
    final String term = value.trim();
    if (term.isEmpty) return;
    _remember(term);
    ref.read(searchCategoriesProvider.notifier).search(term);
    setState(() => _rawQuery = term);
  }

  void _onRecentSelect(String term) {
    _remember(term);
    ref.read(searchCategoriesProvider.notifier).search(term);
    setState(() => _rawQuery = term);
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final RecentKeywordsViewModel recentVm =
        ref.read(recentSearchProvider.notifier);
    final List<String> recentSearches =
        ref.watch(recentSearchProvider).valueOrNull ?? const <String>[];

    final status = PaginationStatus.from(ref.watch(searchCategoriesProvider));

    final bool showNoResult = status.firstPageError != null || status.isEmpty;

    final bool isShimmering = status.isFirstPageLoading;
    if (isShimmering && !_wasShimmering) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) FocusScope.of(context).unfocus();
      });
    }
    _wasShimmering = isShimmering;

    final Widget searchField = PrimarySearchField(
      enableRecentKeywords: true,
      recentKeywords: !showNoResult && _rawQuery.isEmpty
          ? recentSearches
          : const <String>[],
      onChanged: (String value) {
        setState(() => _rawQuery = value);
        if (value.isEmpty) {
          ref.read(searchCategoriesProvider.notifier).search('');
          FocusScope.of(context).unfocus();
        }
      },
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
            if (showNoResult) ...<Widget>[
              searchField,
              Expanded(child: NoResultsWidget()),
            ] else ...<Widget>[
              Flexible(child: searchField),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        LangKeys.bestCategoriesKey.tr(),
                        style: AppTextStyles.style18SemiBold.copyWith(
                          color: colors.black,
                          fontSize: screenWidth * 0.05,
                        ),
                      ),
                      InkWell(
                        onTap: () => context.pushReplacementNamed(
                          AppRoutes.categoriesScreen,
                        ),
                        child: Text(
                          LangKeys.seeAllCategoriesKey.tr(),
                          style: AppTextStyles.style14Medium.copyWith(
                            color: colors.primary500Main,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SearchTopCategoriesList(
                    provider: searchCategoriesProvider,
                    notifier: searchCategoriesProvider.notifier,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
