import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/data/repo/checkout_repo.dart';

/// Single task: draft an order group covering every store in the cart.
///
/// The draft starts as soon as the provider is first watched, so screens only
/// need to `ref.watch(checkoutForAllStoresProvider)` and render the
/// [AsyncValue]. Retry with
/// `ref.read(checkoutForAllStoresProvider.notifier).checkoutForAllStores()`.
final checkoutForAllStoresProvider = StateNotifierProvider.autoDispose<
    CheckoutForAllStoresViewModel, AsyncValue<CheckoutModel>>(
  (Ref ref) =>
      CheckoutForAllStoresViewModel(const AsyncValue.loading())
        ..checkoutForAllStores(),
);

class CheckoutForAllStoresViewModel
    extends StateNotifier<AsyncValue<CheckoutModel>> {
  CheckoutForAllStoresViewModel(super.initialState);

  final CheckoutRepo _repo = CheckoutRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> checkoutForAllStores() async {
    state = const AsyncValue.loading();

    final result = await _repo.checkoutForAllStores();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (CheckoutModel draft) => AsyncValue.data(draft),
    );
  }
}
