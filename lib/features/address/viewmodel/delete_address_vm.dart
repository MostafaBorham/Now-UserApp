import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';

/// Deletes a saved address.
///
/// Pessimistic on purpose: the card stays on the page while the request is in
/// flight, under a blocking overlay, and only leaves once the server confirms
/// the delete. On success the list is refetched from the repo (the same
/// reconcile the add flow does), so the deleted address drops out with the
/// order and pagination counters coming straight from the server. On failure
/// nothing is removed — the address was never taken off the list.
///
/// Like [defaultAddressProvider], this is **not** self-loading on first watch:
/// the address screen drives its blocking overlay off [AsyncValue.isLoading],
/// which must mean "a delete is in flight" and nothing else. `autoDispose`
/// because this action state is scoped to the address screen — leaving it
/// cancels any in-flight request through the repo.
final deleteAddressProvider =
    StateNotifierProvider.autoDispose<DeleteAddressViewModel, AsyncValue<void>>(
      (Ref ref) => DeleteAddressViewModel(ref),
    );

class DeleteAddressViewModel extends StateNotifier<AsyncValue<void>> {
  DeleteAddressViewModel(this._ref)
    : super(const AsyncValue<void>.data(null));

  final Ref _ref;
  final AddressRepo _repo = AddressRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> deleteAddress({required AddressModel address}) async {
    // An address with no id was never saved server-side — nothing to delete.
    final int? addressId = address.id;
    if (addressId == null) return;

    state = const AsyncValue<void>.loading();

    final Either<Failure, Unit> result =
        await _repo.deleteAddress(addressId: addressId);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue<void>.error(failure.message, StackTrace.current),
      (_) {
        // Only now that the server confirmed it: refetch so the deleted address
        // drops out of the list with order and counters from the repo.
        _ref.read(getMyAddressesProvider.notifier).loadFirstPage();
        return const AsyncValue<void>.data(null);
      },
    );
  }
}
