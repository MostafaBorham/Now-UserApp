import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/repo/recent_keywords_repo.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';

/// Manages one search's recent keywords, exposed as `AsyncValue<List<String>>`.
///
/// Every operation replaces the state with the up-to-date list the repo returns,
/// so screens only need to `ref.watch(...)` the provider and render the
/// [AsyncValue]. Which box the keywords live in — and how many are kept — is the
/// [RecentKeywordsRepo] the provider hands in, so products and addresses share
/// this class without sharing their recents.
class RecentKeywordsViewModel extends StateNotifier<AsyncValue<List<String>>> {
  RecentKeywordsViewModel(this._repo) : super(const AsyncValue.loading());

  final RecentKeywordsRepo _repo;

  /// Loads the stored recent keywords. Synchronous read (Hive), so no
  /// `mounted` guard is needed.
  void getRecentSearches() {
    state = const AsyncValue<List<String>>.loading();
    state = _apply(_repo.getRecentSearches());
  }

  /// Narrows the shown keywords to those matching [searchKey]. Synchronous read
  /// (Hive), so no `mounted` guard is needed.
  void filterRecentSearch(String searchKey) {
    state = _apply(_repo.filterRecentSearch(searchKey));
  }

  Future<void> addSearchKey(String keyword) async {
    final result = await _repo.addSearchKey(keyword);
    if (!mounted) return;
    state = _apply(result);
  }

  Future<void> removeSearchKey(String keyword) async {
    final result = await _repo.removeSearchKey(keyword);
    if (!mounted) return;
    state = _apply(result);
  }

  Future<void> clearAll() async {
    final result = await _repo.clearAll();
    if (!mounted) return;
    state = _apply(result);
  }

  AsyncValue<List<String>> _apply(Either<Failure, List<String>> result) {
    return result.fold(
      // The list on screen stays: a failed read or write used to wipe the
      // recent searches from view (QA-003 A17).
      (Failure failure) => AsyncValue<List<String>>.error(
        failure.message,
        StackTrace.current,
      ).copyWithPrevious(state),
      AsyncValue<List<String>>.data,
    );
  }
}
