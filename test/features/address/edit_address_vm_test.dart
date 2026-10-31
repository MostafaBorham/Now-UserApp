import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/remote/api/address_api_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/edit_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';

/// Address 1 is the default; address 2 is not.
class _LoadedList extends GetMyAddressesViewModel {
  _LoadedList() {
    state = const AsyncValue<PaginationModel<AddressModel>>.data(
      PaginationModel<AddressModel>(
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
        total: 2,
        hasMore: false,
        data: <AddressModel>[
          AddressModel(id: 1, isDefault: true),
          AddressModel(id: 2, isDefault: false, floor: '1'),
        ],
      ),
    );
  }
}

/// Saves the edit and answers with it as the new default, the way the server
/// does when the edit ticked "set as default".
class _EditMakesDefault extends AddressApiService {
  @override
  Future<Response> editAddress({
    required int addressId,
    required AddressModel address,
  }) async => Response<dynamic>(
    requestOptions: RequestOptions(path: '/addresses/$addressId'),
    statusCode: 200,
    data: <String, dynamic>{
      'data': <String, dynamic>{
        'address': <String, dynamic>{
          'id': addressId,
          'floor': address.floor,
          'is_default': true,
        },
      },
    },
  );
}

void main() {
  test('editAddress with no id issues no request', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    // The details screen used to call this with `widget.address.id ?? 0`,
    // turning an address that arrived without an id into a PUT to /addresses/0.
    await container
        .read(editAddressProvider.notifier)
        .editAddress(addressId: null, address: const AddressModel());

    // A request would have moved the state to loading on its way out. Staying
    // idle is what proves nothing was sent.
    expect(
      container.read(editAddressProvider),
      const AsyncValue<AddressModel?>.data(null),
    );
  });

  test('an edit that sets the default clears the old one', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        getMyAddressesProvider.overrideWith((Ref ref) => _LoadedList()),
        editAddressProvider.overrideWith(
          (Ref ref) => EditAddressViewModel(
            const AsyncValue<AddressModel?>.data(null),
            ref,
            repo: AddressRepo(
              api: _EditMakesDefault(),
              isConnected: () async => true,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(editAddressProvider, (_, _) {});
    expect(container.read(defaultAddressProvider).valueOrNull?.id, 1);

    await container
        .read(editAddressProvider.notifier)
        .editAddress(
          addressId: 2,
          address: const AddressModel(id: 2, floor: '5', isDefault: true),
        );

    final List<AddressModel> list = container
        .read(getMyAddressesProvider)
        .requireValue
        .data;
    expect(list.map((AddressModel a) => a.id), <int>[2, 1]);
    expect(list.map((AddressModel a) => a.isDefault), <bool>[true, false]);
    expect(list.first.floor, '5', reason: 'the edit itself is kept');
    expect(container.read(defaultAddressProvider).valueOrNull?.id, 2);
  });
}
