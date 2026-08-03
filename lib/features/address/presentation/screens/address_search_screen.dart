import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/features/address/data/models/place_suggestion_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/place_autocomplete_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/recent_address_search_vm.dart';

/// Lets the user find an address by name instead of dragging the map pin.
///
/// The search field behaves exactly like the one on `SearchScreen` — recents
/// live inside [AppSearchField], picking one fills the field and dismisses
/// them — with one addition: the moment the field holds text the recents give
/// way to Google Places suggestions, and picking a suggestion pops back to the
/// map with its coordinates.
class AddressSearchScreen extends ConsumerStatefulWidget {
  const AddressSearchScreen({super.key, this.currentLocation});

  /// Where the map was looking when the search was opened. Sent to Places as a
  /// location bias so nearby addresses rank first; null when unknown.
  final LatLng? currentLocation;

  @override
  ConsumerState<AddressSearchScreen> createState() =>
      _AddressSearchScreenState();
}

class _AddressSearchScreenState extends ConsumerState<AddressSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  /// Place id whose coordinates are being fetched, so only the tapped tile
  /// spins and a second tap cannot start a parallel navigation.
  String? _resolvingPlaceId;

  bool get _hasQuery => _query.trim().isNotEmpty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Every path into a search funnels through here — typing and picking a
  /// recent both mean the same thing to the results list.
  void _onQueryChanged(String value) {
    setState(() => _query = value);
    ref
        .read(placeAutocompleteProvider.notifier)
        .search(
          query: value,
          languageCode: context.locale.languageCode,
          locationBias: widget.currentLocation,
        );
  }

  /// Submitting from the keyboard remembers the term even if the user never
  /// picks a result.
  void _onSubmitted(String value) {
    final String term = value.trim();
    if (term.isEmpty) return;
    ref.read(recentAddressSearchProvider.notifier).addSearchKey(term);
  }

  /// Resolves the picked suggestion to coordinates and hands them back to the
  /// map, which recenters its pin so the user can confirm it before entering
  /// the address details.
  Future<void> _onSuggestionTapped(PlaceSuggestionModel suggestion) async {
    if (_resolvingPlaceId != null) return;
    setState(() => _resolvingPlaceId = suggestion.placeId);

    // A term that led to a pick is worth remembering, and re-adding one that
    // is already stored moves it back to the front.
    final String term = _searchController.text.trim();
    if (term.isNotEmpty) {
      await ref.read(recentAddressSearchProvider.notifier).addSearchKey(term);
      if (!mounted) return;
    }

    final Either<Failure, LatLng> result = await ref
        .read(placeAutocompleteProvider.notifier)
        .resolveLocation(
          placeId: suggestion.placeId,
          languageCode: context.locale.languageCode,
        );

    if (!mounted) return;
    setState(() => _resolvingPlaceId = null);

    result.fold(
      (Failure failure) => ErrorSnackBar.show(context, failure.message),
      (LatLng location) => context.pop(location),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final List<String> recentSearches =
        ref.watch(recentAddressSearchProvider).valueOrNull ?? const <String>[];
    final RecentAddressSearchViewModel recentVm = ref.read(
      recentAddressSearchProvider.notifier,
    );

    final AsyncValue<List<PlaceSuggestionModel>> suggestions = ref.watch(
      placeAutocompleteProvider,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppWavedView(
        appBarTitle: LangKeys.addNewAddress.tr(),
        canPop: context.canPop(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: <Widget>[
            AppSearchField(
              autofocus: true,
              navigateToSearchOnTap: false,
              controller: _searchController,
              hintText: LangKeys.searchForAddressKey.tr(),
              enableRecentKeywords: true,
              // Recents belong to the empty-query state only: handing the
              // field an empty list is what closes them once the user types.
              recentKeywords: _hasQuery ? const <String>[] : recentSearches,
              recentClearLabel: LangKeys.deleteKey.tr(),
              onChanged: _onQueryChanged,
              onSubmitted: _onSubmitted,
              // The field has already filled itself and unfocused, so the
              // recents are gone; all that is left is to search for the term.
              onRecentSelect: _onQueryChanged,
              onRecentRemove: recentVm.removeSearchKey,
              onRecentClear: recentVm.clearAll,
            ),
            Expanded(
              child: !_hasQuery
                  ? const SizedBox(width: double.infinity)
                  : suggestions.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      // `Failure.message` is a LangKeys key or a raw message
                      // from Google — `.tr()` leaves the latter untouched.
                      error: (Object error, StackTrace _) => Center(
                        child: Text(
                          error.toString().tr(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.style16Regular.copyWith(
                            color: colors.tertiaryContainer,
                          ),
                        ),
                      ),
                      data: (List<PlaceSuggestionModel> results) =>
                          results.isEmpty
                          ? Center(
                              child: Text(
                                LangKeys.noAddressResultsKey.tr(),
                                textAlign: TextAlign.center,
                                style: AppTextStyles.style16Regular.copyWith(
                                  color: colors.tertiaryContainer,
                                ),
                              ),
                            )
                          : ListView.separated(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: EdgeInsets.zero,
                              itemCount: results.length,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const SizedBox(height: 4),
                              itemBuilder: (BuildContext context, int index) {
                                final PlaceSuggestionModel suggestion =
                                    results[index];
                                final bool isResolving =
                                    _resolvingPlaceId == suggestion.placeId;

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  onTap: isResolving
                                      ? null
                                      : () => _onSuggestionTapped(suggestion),
                                  leading: SizedBox.square(
                                    dimension: 24,
                                    child: isResolving
                                        ? Center(
                                            child: SizedBox.square(
                                              dimension: 18,
                                              child:
                                                  CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: colors.primary,
                                                  ),
                                            ),
                                          )
                                        : Assets
                                              .media
                                              .images
                                              .svg
                                              .searchIcon
                                              .svg(),
                                  ),
                                  title: Text(
                                    suggestion.mainText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.style16Medium.copyWith(
                                      color: colors.onSecondary,
                                    ),
                                  ),
                                  subtitle: suggestion.secondaryText.isEmpty
                                      ? null
                                      : Text(
                                          suggestion.secondaryText,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.style14Regular
                                              .copyWith(
                                                color: colors.tertiaryContainer,
                                              ),
                                        ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
