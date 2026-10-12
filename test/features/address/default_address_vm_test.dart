import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/remote/api/address_api_service.dart';
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

/// The server already made address 2 the default, but the app never heard:
/// setting it again is a 409, and asking for the default answers 2.
class _ServerHasNewDefault extends AddressApiService {
  Response<dynamic> _answer(int status, Map<String, dynamic> body) =>
      Response<dynamic>(
        requestOptions: RequestOptions(path: '/addresses'),
        statusCode: status,
        data: body,
      );

  @override
  Future<Response> setDefaultAddress({required int addressId}) async =>
      _answer(409, <String, dynamic>{'message': 'Already default'});

  @override
  Future<Response> getDefaultAddress() async => _answer(200, <String, dynamic>{
    'data': <String, dynamic>{
      'address': <String, dynamic>{'id': 2, 'is_default': true},
    },
  });
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

  test('a failed set-default adopts the server\'s default (BUG-025)', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        getMyAddressesProvider.overrideWith((Ref ref) => _LoadedList()),
        defaultAddressProvider.overrideWith(
          (Ref ref) => DefaultAddressViewModel(
            ref,
            repo: AddressRepo(
              api: _ServerHasNewDefault(),
              isConnected: () async => true,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(defaultAddressProvider.notifier)
        .setDefaultAddress(addressId: 2);

    expect(container.read(defaultAddressProvider).valueOrNull?.id, 2);
    final List<AddressModel> list = container
        .read(getMyAddressesProvider)
        .requireValue
        .data;
    expect(list.map((AddressModel a) => a.id), <int>[2, 1]);
    expect(list.map((AddressModel a) => a.isDefault), <bool>[true, false]);
  });

  test('a new default moves to the top and the rest keep their order', () {
    final GetMyAddressesViewModel vm = GetMyAddressesViewModel();
    addTearDown(vm.dispose);
    vm.state = const AsyncValue<PaginationModel<AddressModel>>.data(
      PaginationModel<AddressModel>(
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
        total: 4,
        hasMore: false,
        data: <AddressModel>[
          AddressModel(id: 1, isDefault: true),
          AddressModel(id: 2, isDefault: false),
          AddressModel(id: 3, isDefault: false),
          AddressModel(id: 4, isDefault: false),
        ],
      ),
    );

    vm.updateDefaultInMyAddress(address: const AddressModel(id: 3));

    final List<AddressModel> list = vm.state.requireValue.data;
    expect(list.map((AddressModel a) => a.id), <int>[3, 1, 2, 4]);
    expect(
      list.map((AddressModel a) => a.isDefault),
      <bool>[true, false, false, false],
    );
  });
}
