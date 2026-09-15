import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/repo/recent_keywords_repo.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';








class RecentKeywordsViewModel extends StateNotifier<AsyncValue<List<String>>> {
  RecentKeywordsViewModel(this._repo) : super(const AsyncValue.loading());

  final RecentKeywordsRepo _repo;



  void getRecentSearches() {
    state = const AsyncValue<List<String>>.loading();
    state = _apply(_repo.getRecentSearches());
  }



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
      (Failure failure) =>
          AsyncValue<List<String>>.error(failure.message, StackTrace.current),
      AsyncValue<List<String>>.data,
    );
  }
}
