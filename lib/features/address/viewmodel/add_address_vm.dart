import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';

/// Single task: create a new address for the current user.
///
/// Starts idle (`AsyncValue.data(null)`); on success the data holds the created
/// [AddressModel] returned by the backend. Trigger with
/// `ref.read(addAddressProvider.notifier).addAddress(address: ...)` and watch
/// the provider to react to loading / error / success.
///
/// `autoDispose` because this action state is scoped to the details screen:
/// leaving it cancels any in-flight request through the repo, and does not
/// leave a finished save's result parked for the next visit.
final addAddressProvider =
    StateNotifierProvider.autoDispose<
      AddAddressViewModel,
      AsyncValue<AddressModel?>
    >((Ref ref) => AddAddressViewModel(const AsyncValue.data(null), ref));

class AddAddressViewModel extends StateNotifier<AsyncValue<AddressModel?>> {
  AddAddressViewModel(super.initialState, this._ref);

  final Ref _ref;
  final AddressRepo _repo = AddressRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> addAddress({required AddressModel address}) async {
    state = const AsyncValue.loading();

    final result = await _repo.addAddress(address: address);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (AddressModel created) {
        // Refetch rather than append: the server assigns the id and decides
        // where the new address lands in the list order.
        _ref.read(getMyAddressesProvider.notifier).loadFirstPage();
        return AsyncValue.data(created);
      },
    );
  }
}
