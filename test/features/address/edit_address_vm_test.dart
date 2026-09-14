import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/edit_address_vm.dart';

/// The details screen used to call this with `widget.address.id ?? 0`, turning
/// an address that arrived without an id into a PUT to /addresses/0.
void main() {
  test('editAddress with no id issues no request', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

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
}
