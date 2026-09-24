import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';

const AddressModel _home = AddressModel(id: 1, isDefault: true);

/// A list already loaded with [_home] as the default, which is how the
/// default view model gets seeded after login.
class _LoadedList extends GetMyAddressesViewModel {
  _LoadedList() {
    state = const AsyncValue<PaginationModel<AddressModel>>.data(
      PaginationModel<AddressModel>(
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
        total: 2,
        hasMore: false,
        data: <AddressModel>[_home, AddressModel(id: 2, isDefault: false)],
      ),
    );
  }
}

void main() {
  test('a failed set-default keeps the current default address', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        getMyAddressesProvider.overrideWith((Ref ref) => _LoadedList()),
        defaultAddressProvider.overrideWith(
          (Ref ref) => DefaultAddressViewModel(
            ref,
            // Offline: the repo fails before any request goes out.
            repo: AddressRepo(isConnected: () async => false),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final DefaultAddressViewModel vm = container.read(
      defaultAddressProvider.notifier,
    );
    expect(container.read(defaultAddressProvider).valueOrNull, _home);

    final Future<void> request = vm.setDefaultAddress(addressId: 2);
    // Readers (home header, cart pricing) still see it while the tap is in
    // flight, and the address screen's overlay still sees the request.
    expect(container.read(defaultAddressProvider).valueOrNull, _home);
    expect(container.read(defaultAddressProvider).isLoading, isTrue);

    await request;

    final AsyncValue<AddressModel?> after = container.read(
      defaultAddressProvider,
    );
    expect(after.hasError, isTrue, reason: 'the screen still toasts it');
    expect(after.valueOrNull, _home);
  });
}
