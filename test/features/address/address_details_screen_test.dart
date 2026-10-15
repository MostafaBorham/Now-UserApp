import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/presentation/screens/address_details_screen.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/add_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/edit_address_vm.dart';

import '../../helpers/categories_test_harness.dart';

/// Records what the screen submits instead of sending it.
class _RecordingAdd extends AddAddressViewModel {
  _RecordingAdd(Ref ref)
    : super(const AsyncValue<AddressModel?>.data(null), ref);

  AddressModel? sent;

  @override
  Future<void> addAddress({required AddressModel address}) async =>
      sent = address;
}

class _RecordingEdit extends EditAddressViewModel {
  _RecordingEdit(Ref ref)
    : super(const AsyncValue<AddressModel?>.data(null), ref);

  AddressModel? sent;

  @override
  Future<void> editAddress({
    required int? addressId,
    required AddressModel address,
  }) async => sent = address;
}

/// The field labelled [labelKey] (the harness renders keys as-is).
Finder _field(String labelKey) =>
    find.ancestor(of: find.text(labelKey), matching: find.byType(TextField));
Finder _defaultAddressCheckbox() => find.byType(Checkbox);

String _text(WidgetTester tester, String labelKey) =>
    tester.widget<TextField>(_field(labelKey)).controller!.text;

Future<void> _save(WidgetTester tester) async {
  await tester.ensureVisible(find.text(LangKeys.saveAddress));
  await tester.tap(find.text(LangKeys.saveAddress));
  await tester.pump();
}

/// The server builds `full_address` and the courier's copy from these columns,
/// so the form used to show "Floor Al Noor Tower" by storing floor and building
/// in each other's column.
void main() {
  setUpAll(initCategoriesTestLocalization);

  testWidgets('a home address saves floor, apartment, building, and default '
      'status to their own payload fields', (WidgetTester tester) async {
    late _RecordingAdd vm;
    await pumpCategoriesScreen(
      tester,
      const AddressDetailsScreen(address: AddressModel(area: 'Olaya')),
      overrides: <Override>[
        addAddressProvider.overrideWith((Ref ref) => vm = _RecordingAdd(ref)),
      ],
    );

    expect(tester.widget<Checkbox>(_defaultAddressCheckbox()).value, isFalse);

    await tester.enterText(_field(LangKeys.floor), '3');
    await tester.enterText(_field(LangKeys.apartment), '12');
    await tester.enterText(_field(LangKeys.building), 'Al Noor Tower');
    await tester.tap(find.text(LangKeys.setAsDefaultAddressKey));
    await tester.pump();
    await _save(tester);

    expect(vm.sent?.floor, '3');
    expect(vm.sent?.apartment, '12');
    expect(vm.sent?.buildingNumber, 'Al Noor Tower');
    expect(vm.sent?.isDefault, isTrue);
  });

  testWidgets('an add-address form keeps the backend default payload value '
      'false until the checkbox is selected', (WidgetTester tester) async {
    late _RecordingAdd vm;
    await pumpCategoriesScreen(
      tester,
      const AddressDetailsScreen(address: AddressModel(area: 'Olaya')),
      overrides: <Override>[
        addAddressProvider.overrideWith((Ref ref) => vm = _RecordingAdd(ref)),
      ],
    );

    expect(tester.widget<Checkbox>(_defaultAddressCheckbox()).value, isFalse);

    await tester.enterText(_field(LangKeys.floor), '3');
    await tester.enterText(_field(LangKeys.building), 'Al Noor Tower');
    await tester.pump();
    await _save(tester);

    expect(vm.sent?.isDefault, isFalse);
  });

  testWidgets('a default address initializes checked and persists an '
      'unchecked edit back through the update flow', (
    WidgetTester tester,
  ) async {
    late _RecordingEdit vm;
    await pumpCategoriesScreen(
      tester,
      const AddressDetailsScreen(
        isEditScreen: true,
        address: AddressModel(
          id: 7,
          area: 'Olaya',
          label: <String, dynamic>{'en': 'Work', 'ar': 'العمل'},
          apartment: 'Acme',
          floor: '5',
          buildingNumber: 'Tower B',
          isDefault: true,
        ),
      ),
      overrides: <Override>[
        editAddressProvider.overrideWith((Ref ref) => vm = _RecordingEdit(ref)),
      ],
    );

    expect(
      tester.widget<TextField>(_field(LangKeys.floorWork)).controller?.text,
      'Acme',
    );
    expect(
      tester
          .widget<TextField>(_field(LangKeys.floorNumberOptional))
          .controller
          ?.text,
      '5',
    );
    expect(tester.widget<Checkbox>(_defaultAddressCheckbox()).value, isTrue);

    await tester.tap(find.text(LangKeys.setAsDefaultAddressKey));
    await tester.pump();
    await _save(tester);

    expect(vm.sent?.apartment, 'Acme');
    expect(vm.sent?.floor, '5');
    expect(vm.sent?.buildingNumber, 'Tower B');
    expect(vm.sent?.isDefault, isFalse);
  });

  testWidgets('a non-default address initializes unchecked and persists a '
      'checked edit back through the update flow', (WidgetTester tester) async {
    late _RecordingEdit vm;
    await pumpCategoriesScreen(
      tester,
      const AddressDetailsScreen(
        isEditScreen: true,
        address: AddressModel(
          id: 8,
          area: 'Olaya',
          label: <String, dynamic>{'en': 'Home', 'ar': 'المنزل'},
          floor: '2',
          apartment: '12',
          buildingNumber: 'Tower C',
          isDefault: false,
        ),
      ),
      overrides: <Override>[
        editAddressProvider.overrideWith((Ref ref) => vm = _RecordingEdit(ref)),
      ],
    );

    expect(tester.widget<Checkbox>(_defaultAddressCheckbox()).value, isFalse);

    await tester.tap(find.text(LangKeys.setAsDefaultAddressKey));
    await tester.pump();
    await _save(tester);

    expect(vm.sent?.isDefault, isTrue);
  });

  testWidgets('the checkbox resets when the same form is rebuilt for another '
      'address', (WidgetTester tester) async {
    await pumpCategoriesScreen(
      tester,
      const AddressDetailsScreen(
        isEditScreen: true,
        address: AddressModel(
          id: 7,
          area: 'Olaya',
          label: <String, dynamic>{'en': 'Home', 'ar': 'المنزل'},
          floor: '3',
          buildingNumber: 'Tower A',
          isDefault: true,
        ),
      ),
    );

    expect(tester.widget<Checkbox>(_defaultAddressCheckbox()).value, isTrue);

    await pumpCategoriesScreen(
      tester,
      const AddressDetailsScreen(
        isEditScreen: true,
        address: AddressModel(
          id: 8,
          area: 'Olaya',
          label: <String, dynamic>{'en': 'Home', 'ar': 'المنزل'},
          floor: '2',
          buildingNumber: 'Tower B',
          isDefault: false,
        ),
      ),
    );

    expect(tester.widget<Checkbox>(_defaultAddressCheckbox()).value, isFalse);
  });

  testWidgets('floor takes 4 digits, apartment 5, and text drops emoji '
      '(BUG-021, BUG-022)', (WidgetTester tester) async {
    await pumpCategoriesScreen(
      tester,
      const AddressDetailsScreen(address: AddressModel(area: 'Olaya')),
    );

    await tester.enterText(_field(LangKeys.floor), '123456789012345678');
    await tester.enterText(_field(LangKeys.apartment), '123456789');
    await tester.enterText(_field(LangKeys.building), 'Tower 😀🇸🇦👍🏽❤️ B');
    await tester.pump();

    expect(_text(tester, LangKeys.floor), '1234');
    expect(_text(tester, LangKeys.apartment), '12345');
    expect(_text(tester, LangKeys.building), 'Tower  B');
  });
}
