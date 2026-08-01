import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';

/// Single task: mark one of the user's saved addresses as the default.
///
/// Starts idle (`AsyncValue.data(null)`); on success the data holds the updated
/// [AddressModel] returned by the backend, so callers can merge it into the
/// address list they already show. Trigger with
/// `ref.read(setDefaultAddressProvider.notifier).setDefaultAddress(addressId: ...)`
/// and watch the provider to react to loading / error / success.
final defaultAddressProvider =
    StateNotifierProvider<DefaultAddressViewModel, AsyncValue<AddressModel?>>(
      (Ref ref) => DefaultAddressViewModel(const AsyncValue.data(null),ref),
    );

class DefaultAddressViewModel extends StateNotifier<AsyncValue<AddressModel?>> {
  DefaultAddressViewModel(super.initialState,this._ref);

  final Ref _ref;
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
      (AddressModel address) {
        _ref.read(getMyAddressesProvider.notifier).updateDefaultInMyAddress(address: address);
        return AsyncValue.data(address);
      },
    );
  }
}
