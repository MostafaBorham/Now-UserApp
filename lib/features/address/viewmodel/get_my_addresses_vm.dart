import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';

/// Single task: fetch the current user's saved addresses.
///
/// The fetch starts as soon as the provider is first watched, so screens only
/// need to `ref.watch(getMyAddressesProvider)` and render the [AsyncValue].
/// Retry with `ref.read(getMyAddressesProvider.notifier).getMyAddresses()`.
final getMyAddressesProvider = StateNotifierProvider.autoDispose<
    GetMyAddressesViewModel, AsyncValue<List<AddressModel>>>(
  (Ref ref) =>
      GetMyAddressesViewModel(const AsyncValue.loading())..getMyAddresses(),
);

class GetMyAddressesViewModel
    extends StateNotifier<AsyncValue<List<AddressModel>>> {
  GetMyAddressesViewModel(super.initialState);

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
      (List<AddressModel> addresses) => AsyncValue.data(addresses),
    );
  }
}
