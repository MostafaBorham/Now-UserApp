import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/repo/checkout_repo.dart';

/// Single task: draft an order group for one store, keyed by its `vendorId`.
///
/// The draft starts as soon as the provider is first watched, so screens only
/// need to `ref.watch(checkoutForSingleStoreProvider(vendorId))` and render the
/// [AsyncValue]. Retry with
/// `ref.read(checkoutForSingleStoreProvider(vendorId).notifier).checkoutForSingleStore()`.
final checkoutForSingleStoreProvider = StateNotifierProvider.autoDispose
    .family<CheckoutForSingleStoreViewModel, AsyncValue<CheckoutModel>,
        int>(
  (Ref ref, int vendorId) =>
      CheckoutForSingleStoreViewModel(vendorId)..checkoutForSingleStore(),
);

class CheckoutForSingleStoreViewModel
    extends StateNotifier<AsyncValue<CheckoutModel>> {
  CheckoutForSingleStoreViewModel(this._vendorId)
      : super(const AsyncValue.loading());

  final int _vendorId;
  final CheckoutRepo _repo = CheckoutRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> checkoutForSingleStore() async {
    state = const AsyncValue.loading();

    final result = await _repo.checkoutForSingleStore(_vendorId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (CheckoutModel draft) => AsyncValue.data(draft),
    );
  }
}
