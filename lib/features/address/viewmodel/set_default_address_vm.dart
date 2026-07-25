import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';

/// Single task: mark one of the user's saved addresses as the default.
///
/// Starts idle (`AsyncValue.data(null)`). Trigger with
/// `ref.read(setDefaultAddressProvider.notifier).setDefaultAddress(addressId: ...)`
/// and watch the provider to react to loading / error / success.
final setDefaultAddressProvider = StateNotifierProvider.autoDispose<
    SetDefaultAddressViewModel, AsyncValue<void>>(
  (Ref ref) => SetDefaultAddressViewModel(const AsyncValue.data(null)),
);

class SetDefaultAddressViewModel extends StateNotifier<AsyncValue<void>> {
  SetDefaultAddressViewModel(super.initialState);

  final AddressRepo _repo = AddressRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> setDefaultAddress({required int addressId}) async {
    state = const AsyncValue.loading();

    final result = await _repo.setDefaultAddress(addressId: addressId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }
}
