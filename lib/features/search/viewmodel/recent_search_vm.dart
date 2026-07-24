import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/search/data/repo/search_repo.dart';

/// Manages the user's recent search keywords for the search screen.
///
/// Exposes the list as `AsyncValue<List<String>>` and loads it as soon as the
/// provider is first watched, so screens only need to
/// `ref.watch(recentSearchProvider)` and render the [AsyncValue]. The four
/// operations map one-to-one to the recents view:
/// [getRecentSearches], [addSearchKey], [removeSearchKey] and [clearAll].
/// Each mutation persists through the repo and replaces the state with the
/// up-to-date list.
///
/// Not yet wired into the search UI — that happens in a later task.
final recentSearchProvider =
    StateNotifierProvider.autoDispose<
      RecentSearchViewModel,
      AsyncValue<List<String>>
    >(
      (Ref ref) =>
          RecentSearchViewModel(const AsyncValue.loading())
            ..getRecentSearches(),
    );

class RecentSearchViewModel extends StateNotifier<AsyncValue<List<String>>> {
  RecentSearchViewModel(super.initialState);

  final SearchRepo _repo = SearchRepo();

  /// Loads the stored recent keywords. Synchronous read (Hive), so no
  /// `mounted` guard is needed.
  void getRecentSearches() {
    state = const AsyncValue.loading();
    state = _repo.getRecentSearches().fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (List<String> keywords) => AsyncValue.data(keywords),
    );
  }

  /// Filters the recent keywords by [searchKey] and replaces the state with the
  /// matches. Synchronous read (Hive), so no `mounted` guard is needed.
  void filterRecentSearch(String searchKey) {
    state = _repo.filterRecentSearch(searchKey).fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (List<String> keywords) => AsyncValue.data(keywords),
    );
  }

  Future<void> addSearchKey(String keyword) async {
    final result = await _repo.addSearchKey(keyword);
    if (!mounted) return;
    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (List<String> keywords) => AsyncValue.data(keywords),
    );
  }

  Future<void> removeSearchKey(String keyword) async {
    final result = await _repo.removeSearchKey(keyword);
    if (!mounted) return;
    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (List<String> keywords) => AsyncValue.data(keywords),
    );
  }

  Future<void> clearAll() async {
    final result = await _repo.clearAll();
    if (!mounted) return;
    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (List<String> keywords) => AsyncValue.data(keywords),
    );
  }
}
