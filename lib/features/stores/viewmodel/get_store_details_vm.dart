import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/stores/data/repo/stores_repo.dart';

/// Single task: fetch the details of one store for the store details screen.
///
/// The fetch starts as soon as the provider is first watched, so screens only
/// need to `ref.watch(getStoreDetailsProvider(storeId))` and render the
/// [AsyncValue].
/// Retry with `ref.read(getStoreDetailsProvider(storeId).notifier).getStoreDetails()`.
final getStoreDetailsProvider = StateNotifierProvider.autoDispose.family<
    GetStoreDetailsViewModel,
    AsyncValue<StoreModel>,
    int>(
      (ref, storeId) {
    return GetStoreDetailsViewModel(const AsyncValue.loading(), storeId: storeId)
      ..getStoreDetails();
  },
);

class GetStoreDetailsViewModel
    extends StateNotifier<AsyncValue<StoreModel>> {
  GetStoreDetailsViewModel(super.initialState, {required this.storeId});

  final int storeId;
  final StoresRepo _repo = StoresRepo();

  Future<void> getStoreDetails() async {
    state = const AsyncValue.loading();

    final result = await _repo.getStoreDetails(storeId: 3);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (StoreModel store) => AsyncValue.data(store),
    );
  }
}
