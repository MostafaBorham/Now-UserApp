import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';













final defaultAddressProvider =
    StateNotifierProvider<DefaultAddressViewModel, AsyncValue<AddressModel?>>(
      (Ref ref) => DefaultAddressViewModel(ref),
    );

class DefaultAddressViewModel extends StateNotifier<AsyncValue<AddressModel?>> {
  DefaultAddressViewModel(this._ref)
    : super(const AsyncValue<AddressModel?>.data(null)) {
    _listenToMyAddresses();
  }

  final Ref _ref;
  final AddressRepo _repo = AddressRepo();







  void _listenToMyAddresses() {
    _ref.listen<AsyncValue<PaginationModel<AddressModel>>>(
      getMyAddressesProvider,
      (_, AsyncValue<PaginationModel<AddressModel>> next) =>
          _syncDefaultFromList(next.valueOrNull),
      fireImmediately: true,
    );
  }








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
