import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
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
  /// [repo] is injectable for tests only, like [AddressRepo]'s own seams.
  DefaultAddressViewModel(this._ref, {AddressRepo? repo})
    : _repo = repo ?? AddressRepo(),
      super(const AsyncValue<AddressModel?>.data(null)) {
    _listenToMyAddresses();
  }

  final Ref _ref;
  final AddressRepo _repo;

  /// Keeps the default in step with the loaded address list: every time the
  /// list resolves to data (add, edit, delete, refetch), the default is
  /// re-derived from it so the checkout delivery card never shows a stale one.
  ///
  /// `fireImmediately` covers the case where the list has already resolved
  /// before this viewmodel is first watched.
  void _listenToMyAddresses() {
    _ref.listen<AsyncValue<PaginationModel<AddressModel>>>(
      getMyAddressesProvider,
      (_, AsyncValue<PaginationModel<AddressModel>> next) =>
          _syncDefaultFromList(next.valueOrNull),
      fireImmediately: true,
    );
  }

  /// Re-derives the default from [addresses]:
  /// - an address the list marks `isDefault` becomes the default (authoritative,
  ///   since [setDefaultAddress] patches the list to match);
  /// - an empty list clears the default to `null`, so deleting the last address
  ///   drops it out of the checkout card instead of leaving it stale;
  /// - a non-empty list with no `isDefault` flag on the loaded pages is left
  ///   untouched — the real default may sit on a page that wasn't fetched.
  void _syncDefaultFromList(PaginationModel<AddressModel>? addresses) {
    if (addresses == null) return;

    for (final AddressModel address in addresses.data) {
      if (address.isDefault ?? false) {
        if (state.valueOrNull?.id != address.id) {
          state = AsyncValue<AddressModel?>.data(address);
        }
        return;
      }
    }

    if (addresses.data.isEmpty && state.valueOrNull != null) {
      state = const AsyncValue<AddressModel?>.data(null);
    }
  }

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
    state = _loadingOverCurrent();

    final result = await _repo.getDefaultAddress();

    if (!mounted) return;

    state = result.fold(
      _errorOverCurrent,
      (AddressModel address) => AsyncValue<AddressModel?>.data(address),
    );
  }

  /// Loading and error keep the address already held. Every reader goes
  /// through `valueOrNull` — the home header, cart pricing — and a bare
  /// loading/error state has none, so one failed tap used to drop the user's
  /// default everywhere until the address list next changed.
  AsyncValue<AddressModel?> _loadingOverCurrent() =>
      const AsyncValue<AddressModel?>.loading().copyWithPrevious(state);

  AsyncValue<AddressModel?> _errorOverCurrent(Failure failure) =>
      AsyncValue<AddressModel?>.error(
        failure.message,
        StackTrace.current,
      ).copyWithPrevious(state);

  /// Adopts [address] when it *is* the loaded default, so an edit to it shows
  /// up wherever the default is read — the checkout delivery card — instead of
  /// staying stale until the next login. The mirror of the list patching
  /// [setDefaultAddress] does, for the other direction of the same data.
  void syncEditedAddress({required AddressModel address}) {
    if (address.id == null || address.id != state.valueOrNull?.id) return;
    state = AsyncValue<AddressModel?>.data(address);
  }

  Future<void> setDefaultAddress({required int addressId}) async {
    state = _loadingOverCurrent();

    final result = await _repo.setDefaultAddress(addressId: addressId);

    if (!mounted) return;

    state = result.fold(_errorOverCurrent, (AddressModel address) {
      _ref
          .read(getMyAddressesProvider.notifier)
          .updateDefaultInMyAddress(address: address);
      return AsyncValue<AddressModel?>.data(address);
    });
  }
}
