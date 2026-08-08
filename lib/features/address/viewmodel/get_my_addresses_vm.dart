import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';

/// Single task: fetch the current user's saved addresses.
///
/// The fetch starts as soon as the provider is first watched, so screens only
/// need to `ref.watch(getMyAddressesProvider)` and render the [AsyncValue].
/// Retry with `ref.read(getMyAddressesProvider.notifier).getMyAddresses()`.
final getMyAddressesProvider =
    StateNotifierProvider<
      GetMyAddressesViewModel,
      AsyncValue<List<AddressModel>>
    >((Ref ref) => GetMyAddressesViewModel(const AsyncValue.loading(), ref));

class GetMyAddressesViewModel
    extends StateNotifier<AsyncValue<List<AddressModel>>> {
  GetMyAddressesViewModel(super.initialState, this._ref);

  final Ref _ref;
  final AddressRepo _repo = AddressRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getMyAddresses() async {
    state = const AsyncValue.loading();

    final result = await _repo.getMyAddresses();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (List<AddressModel> addresses) {
        _ref
            .read(defaultAddressProvider.notifier)
            .setDefaultFromAddresses(addresses: addresses);
        return AsyncValue.data(addresses);
      },
    );
  }

  void addNewAddress({required AddressModel address}) {
    final List<AddressModel>? addresses = state.value;

    if (addresses == null) return;

    state = AsyncValue.data(<AddressModel>[...addresses, address]);
  }

  void updateAddress({required AddressModel address}) {
    final List<AddressModel>? addresses = state.value;

    if (addresses == null) return;

    final bool exists = addresses.any(
      (AddressModel current) => current.id == address.id,
    );

    if (!exists) return;

    state = AsyncValue.data(
      addresses
          .map(
            (AddressModel current) =>
                current.id == address.id ? address : current,
          )
          .toList(),
    );
  }

  void updateDefaultInMyAddress({required AddressModel address}) {
    final List<AddressModel>? addresses = state.value;

    if (addresses == null) return;

    final bool exists = addresses.any(
      (AddressModel current) => current.id == address.id,
    );

    if (!exists) return;

    state = AsyncValue.data(
      addresses
          .map(
            (AddressModel current) =>
                current.copyWith(isDefault: current.id == address.id),
          )
          .toList(),
    );
  }
}