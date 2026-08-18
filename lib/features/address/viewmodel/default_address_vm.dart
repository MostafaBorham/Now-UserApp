import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';

/// The user's default delivery address: reads it, and marks a different one as
/// default.
///
/// Filled from `GET /addresses/default` by `AuthSessionViewModel` at login,
/// alongside the address list, so every consumer — the address list, the
/// checkout card — reads the same answer without depending on some other
/// screen having populated it first. On a successful [setDefaultAddress] the
/// loaded address list is patched in place, so the two never disagree.
///
/// Not self-loading on first watch on purpose: the address screen drives a
/// blocking overlay off [AsyncValue.isLoading], which must mean "a set-default
/// tap is in flight" and nothing else.
final defaultAddressProvider =
    StateNotifierProvider<DefaultAddressViewModel, AsyncValue<AddressModel?>>(
      (Ref ref) => DefaultAddressViewModel(ref),
    );

class DefaultAddressViewModel extends StateNotifier<AsyncValue<AddressModel?>> {
  DefaultAddressViewModel(this._ref)
    : super(const AsyncValue<AddressModel?>.data(null));

  final Ref _ref;
  final AddressRepo _repo = AddressRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  /// Reads the current default straight from the server.
  ///
  /// Deliberately not derived from the loaded address list: the list is
  /// paginated, so a default sitting on page 2 would never be found.
  Future<void> getDefaultAddress() async {
    state = const AsyncValue<AddressModel?>.loading();

    final result = await _repo.getDefaultAddress();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue<AddressModel?>.error(failure.message, StackTrace.current),
      (AddressModel address) => AsyncValue<AddressModel?>.data(address),
    );
  }

  /// Adopts [address] when it *is* the loaded default, so an edit to it shows
  /// up wherever the default is read — the checkout delivery card — instead of
  /// staying stale until the next login. The mirror of the list patching
  /// [setDefaultAddress] does, for the other direction of the same data.
  void syncEditedAddress({required AddressModel address}) {
    if (address.id == null || address.id != state.valueOrNull?.id) return;
    state = AsyncValue<AddressModel?>.data(address);
  }

  Future<void> setDefaultAddress({required int addressId}) async {
    state = const AsyncValue<AddressModel?>.loading();

    final result = await _repo.setDefaultAddress(addressId: addressId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue<AddressModel?>.error(failure.message, StackTrace.current),
      (AddressModel address) {
        _ref
            .read(getMyAddressesProvider.notifier)
            .updateDefaultInMyAddress(address: address);
        return AsyncValue<AddressModel?>.data(address);
      },
    );
  }
}
