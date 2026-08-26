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
  /// The live field text, updated on every keystroke. Drives only the recents
  /// visibility (they belong to the empty-query state), so it never waits on the
  /// debounce.
  String _rawQuery = '';

  /// Whether the categories list was in its shimmer (first-page loading) state
  /// on the previous build — so focus is dropped once, right as it enters it.
  bool _wasShimmering = false;

  /// Remembers a searched term. Used by keyboard-submit, by picking a recent,
  /// and by the debounce (so a searched term is kept without submitting).
  void _remember(String term) {
    if (term.isEmpty) return;
    ref.read(recentSearchProvider.notifier).addSearchKey(term);
  }

  /// Fires ~1s after typing stops: run the search for the term (which starts the
  /// list's shimmer) and remember it so the recents fill up. Focus is dropped by
  /// the list entering its shimmer state (see `build`), not from here.
  void _onSearch(String value) {
    if (!mounted) return;
    final String term = value.trim();
    ref.read(searchCategoriesProvider.notifier).search(term);
    _remember(term);
  }

  /// Submitting from the keyboard remembers the term and searches for it now.
  void _onSubmitted(String value) {
    final String term = value.trim();
    if (term.isEmpty) return;
    _remember(term);
    ref.read(searchCategoriesProvider.notifier).search(term);
    setState(() => _rawQuery = term);
  }

  /// Picking a recent: the field has already filled itself and unfocused, so
  /// this just moves the term to the front of the recents and searches for it.
  void _onRecentSelect(String term) {
    _remember(term);
    ref.read(searchCategoriesProvider.notifier).search(term);
    setState(() => _rawQuery = term);
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

    // The search screen's own categories list: narrowed by the search term and
    // seeded from the shared, app-wide categories on open (never refetched for
    // the unfiltered case). See [searchCategoriesProvider].
    final status = PaginationStatus.from(ref.watch(searchCategoriesProvider));

    // A first-page failure or an empty result drops the whole categories
    // section and shows the no-results widget centred in its place instead.
    final bool showNoResult = status.firstPageError != null || status.isEmpty;

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
      onChanged: (String value) {
        setState(() => _rawQuery = value);
        // Clearing the field returns to the unfiltered list (seeded from the
        // shared app categories, no request) and drops focus so the recents and
        // keyboard close rather than reopening on the now-empty field.
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
                  // Sizes its own height to the card (a third of the screen wide
                  // at a fixed aspect ratio), so no Expanded/AspectRatio here.
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
