import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';

/// Single task: update an existing address for the current user.
///
/// Starts idle (`AsyncValue.data(null)`); on success the data holds the updated
/// [AddressModel] returned by the backend. Trigger with
/// `ref.read(editAddressProvider.notifier).editAddress(addressId: ..., address: ...)`
/// and watch the provider to react to loading / error / success.
final editAddressProvider =
    StateNotifierProvider<EditAddressViewModel, AsyncValue<AddressModel?>>(
      (Ref ref) => EditAddressViewModel(const AsyncValue.data(null), ref),
    );

class EditAddressViewModel extends StateNotifier<AsyncValue<AddressModel?>> {
  EditAddressViewModel(super.initialState, this._ref);

  final Ref _ref;
  final AddressRepo _repo = AddressRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> editAddress({
    required int addressId,
    required AddressModel address,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repo.editAddress(
      addressId: addressId,
      address: address,
    );

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (AddressModel updated) {
        _ref
            .read(getMyAddressesProvider.notifier)
            .updateAddress(address: updated);
        return AsyncValue.data(updated);
      },
    );
  }
}
