import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';











final editAddressProvider =
    StateNotifierProvider.autoDispose<
      EditAddressViewModel,
      AsyncValue<AddressModel?>
    >((Ref ref) => EditAddressViewModel(const AsyncValue.data(null), ref));

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
    required int? addressId,
    required AddressModel address,
  }) async {




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
        _ref
            .read(getMyAddressesProvider.notifier)
            .updateAddress(address: updated);
        _ref
            .read(defaultAddressProvider.notifier)
            .syncEditedAddress(address: updated);
        return AsyncValue.data(updated);
      },
    );
  }
}
