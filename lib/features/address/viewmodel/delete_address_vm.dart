import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';















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


        _ref.read(getMyAddressesProvider.notifier).loadFirstPage();
        return const AsyncValue<void>.data(null);
      },
    );
  }
}
