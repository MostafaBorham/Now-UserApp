import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/pagination_status.dart';
import 'package:nowdelivery_user_app/core/viewmodel/recent_keywords_view_model.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search_top_categories_list.dart';
import 'package:nowdelivery_user_app/features/search/viewmodel/recent_search_vm.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  /// The live field text, updated on every keystroke. Drives only the recents
  /// visibility (they belong to the empty-query state), so it never waits on the
  /// debounce.
  String _rawQuery = '';

  /// The debounced term the categories are queried with — the family key of
  /// [searchAppCategoriesProvider]. Empty is a real query too: it fetches the
  /// full list, so clearing the field re-runs the search with no term.
  String _searchQuery = '';

  /// Whether the categories list was in its shimmer (first-page loading) state
  /// on the previous build — so focus is dropped once, right as it enters it.
  bool _wasShimmering = false;

  @override
  void initState() {
    super.initState();
    // The empty-term strip reuses the shared, kept-alive app categories that
    // the splash preloads — opening the search screen must not refetch them.
    // Only retry when that shared load actually failed; a loaded (or still
    // in-flight) list is left untouched.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(getAppCategoriesProvider).hasError) {
        ref.read(getAppCategoriesProvider.notifier).loadFirstPage();
      }
    });
  }

  /// Remembers a searched term. Used by keyboard-submit, by picking a recent,
  /// and by the debounce (so a searched term is kept without submitting).
  void _remember(String term) {
    if (term.isEmpty) return;
    ref.read(recentSearchProvider.notifier).addSearchKey(term);
  }

  /// Fires ~1s after typing stops: apply the term (which starts the list's
  /// shimmer) and remember it so the recents fill up. Focus is dropped by the
  /// list entering its shimmer state (see `build`), not from here.
  void _onSearch(String value) {
    if (!mounted) return;
    final String term = value.trim();
    setState(() => _searchQuery = term);
    _remember(term);
  }

  /// Submitting from the keyboard remembers the term and searches for it now.
  void _onSubmitted(String value) {
    final String term = value.trim();
    if (term.isEmpty) return;
    _remember(term);
    setState(() {
      _rawQuery = term;
      _searchQuery = term;
    });
  }

  /// Picking a recent: the field has already filled itself and unfocused, so
  /// this just moves the term to the front of the recents and searches for it.
  void _onRecentSelect(String term) {
    _remember(term);
    setState(() {
      _rawQuery = term;
      _searchQuery = term;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    // Recent search keywords (loaded on first watch by the provider).
    final RecentKeywordsViewModel recentVm =
        ref.read(recentSearchProvider.notifier);
    final List<String> recentSearches =
        ref.watch(recentSearchProvider).valueOrNull ?? const <String>[];

    // Empty term reuses the shared, kept-alive provider (preloaded at splash,
    // not refetched each open); a real term uses its own autoDispose family
    // member so searched pages don't linger or mutate the shared list.
    final bool isSearching = _searchQuery.isNotEmpty;
    final ProviderListenable<AsyncValue<PaginationModel<CategoryModel>>>
        categoriesProvider = isSearching
        ? searchAppCategoriesProvider(_searchQuery)
        : getAppCategoriesProvider;
    final ProviderListenable<GetAppCategoriesViewModel> categoriesNotifier =
        isSearching
        ? searchAppCategoriesProvider(_searchQuery).notifier
        : getAppCategoriesProvider.notifier;

    // A first-page failure or an empty result drops the whole categories
    // section and shows the no-results widget centred in its place instead.
    final status = PaginationStatus.from(ref.watch(categoriesProvider));
    final bool showNoResult =
        status.firstPageError != null || status.isEmpty;

    // The rule: the moment the list flips into its shimmer (first-page loading)
    // state, drop focus from the search field — which in turn closes the recents
    // and the keyboard. Only on the transition into shimmer, so it fires once.
    final bool isShimmering = status.isFirstPageLoading;
    if (isShimmering && !_wasShimmering) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) FocusScope.of(context).unfocus();
      });
    }
    _wasShimmering = isShimmering;

    // The field owns its recents; it shows them while focused. They belong to
    // the empty-query state only (and never over the no-results view), so an
    // empty list is what closes them once the user types.
    final Widget searchField = PrimarySearchField(
      enableRecentKeywords: true,
      recentKeywords: !showNoResult && _rawQuery.isEmpty
          ? recentSearches
          : const <String>[],
      onChanged: (String value) => setState(() => _rawQuery = value),
      onSearch: _onSearch,
      onSubmitted: _onSubmitted,
      onRecentSelect: _onRecentSelect,
      onRecentRemove: recentVm.removeSearchKey,
      onRecentClear: recentVm.clearAll,
    );

    return Scaffold(
      // The keyboard must not resize the page (no overflow, no upward shift);
      // it just overlays the bottom.
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
              // Categories section gone; the widget takes the whole remaining
              // space under the search field and sits centred in it.
              Expanded(child: NoResultsWidget()),
            ] else ...<Widget>[
              // The field takes the remaining space so its recents can fill and
              // scroll within it; the categories then sit after it (req).
              Flexible(child: searchField),
              AspectRatio(
                aspectRatio: 2,
                child: Column(
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
                          // Leave the search screen behind on the way to the
                          // full categories list.
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
                    Expanded(
                      child: SearchTopCategoriesList(
                        provider: categoriesProvider,
                        notifier: categoriesNotifier,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
