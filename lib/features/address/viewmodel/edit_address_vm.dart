import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';

/// Single task: update an existing address for the current user.
///
/// Starts idle (`AsyncValue.data(null)`); on success the data holds the updated
/// [AddressModel] returned by the backend. Trigger with
/// `ref.read(editAddressProvider.notifier).editAddress(addressId: ..., address: ...)`
/// and watch the provider to react to loading / error / success.
///
/// `autoDispose` because this action state is scoped to the details screen:
/// leaving it cancels any in-flight request through the repo, and does not
/// leave a finished save's result parked for the next visit.
final editAddressProvider =
    StateNotifierProvider.autoDispose<
      EditAddressViewModel,
      AsyncValue<AddressModel?>
    >((Ref ref) => EditAddressViewModel(const AsyncValue.data(null), ref));

class EditAddressViewModel extends StateNotifier<AsyncValue<AddressModel?>> {
  /// [repo] is injectable for tests only, like [AddressRepo]'s own seams.
  EditAddressViewModel(super.initialState, this._ref, {AddressRepo? repo})
    : _repo = repo ?? AddressRepo();

  final Ref _ref;
  final AddressRepo _repo;

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> editAddress({
    required int? addressId,
    required AddressModel address,
  }) async {
    // An address with no id was never saved server-side — there is nothing to
    // update, and the caller's `?? 0` fallback used to turn that into a PUT to
    // /addresses/0. Guarded here rather than at the call site so every caller
    // is covered, the way [DeleteAddressViewModel.deleteAddress] does it.
    if (addressId == null) return;

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
        final GetMyAddressesViewModel addresses = _ref.read(
          getMyAddressesProvider.notifier,
        )..updateAddress(address: updated);
        // Ticking "set as default" on an edit makes the server demote the old
        // default. Patching only this row left both cards reading "default",
        // and the checkout kept the old one (the first flagged row wins).
        if (updated.isDefault ?? false) {
          addresses.updateDefaultInMyAddress(address: updated);
        }
        _ref
            .read(defaultAddressProvider.notifier)
            .syncEditedAddress(address: updated);
        return AsyncValue.data(updated);
      },
    );
  }
}
