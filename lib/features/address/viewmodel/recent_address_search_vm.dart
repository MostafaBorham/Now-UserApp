import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_search_repo.dart';

/// Manages the recent keywords of the address search screen.
///
/// The address twin of `recentSearchProvider`: same shape and the same four
/// operations, backed by its own Hive box. Exposes the list as
/// `AsyncValue<List<String>>` and loads it as soon as the provider is first
/// watched, so the screen only needs to
/// `ref.watch(recentAddressSearchProvider)` and render the [AsyncValue].
final recentAddressSearchProvider =
    StateNotifierProvider.autoDispose<
      RecentAddressSearchViewModel,
      AsyncValue<List<String>>
    >(
      (Ref ref) =>
          RecentAddressSearchViewModel(const AsyncValue.loading())
            ..getRecentSearches(),
    );

class RecentAddressSearchViewModel
    extends StateNotifier<AsyncValue<List<String>>> {
  RecentAddressSearchViewModel(super.initialState);

  final AddressSearchRepo _repo = AddressSearchRepo();

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
