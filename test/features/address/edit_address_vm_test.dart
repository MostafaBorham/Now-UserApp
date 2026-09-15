import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/edit_address_vm.dart';



void main() {
  test('editAddress with no id issues no request', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(editAddressProvider.notifier)
        .editAddress(addressId: null, address: const AddressModel());



    expect(
      container.read(editAddressProvider),
      const AsyncValue<AddressModel?>.data(null),
    );
  });
}
