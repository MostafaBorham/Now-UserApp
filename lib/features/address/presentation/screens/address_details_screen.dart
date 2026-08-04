import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_segmented_selector.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/app_validator.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/add_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/edit_address_vm.dart';
import '../../../settings/app_colors.dart';
import '../widgets/address_field.dart';
import '../widgets/area_selector.dart';

class AddressDetailsScreen extends ConsumerStatefulWidget {
  const AddressDetailsScreen({
    super.key,
    required this.address,
    this.cameFromMap = false,
    this.isEditScreen = false,
  });

  final AddressModel address;

  /// True when this screen was pushed from the map, which is therefore still
  /// in the stack — "Change" pops back to it instead of opening a new map.
  final bool cameFromMap;

  /// True when editing an existing address (opened from the address list),
  /// false when creating a new one. Drives the app bar title, the prefilled
  /// field values, and which viewmodel the Save button submits to.
  final bool isEditScreen;

  @override
  ConsumerState<AddressDetailsScreen> createState() =>
      _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends ConsumerState<AddressDetailsScreen> {
  late final TextEditingController _phoneController;
  late final TextEditingController _floorNumberController;
  late final TextEditingController _buildingNameController;
  late final TextEditingController _apartmentController;
  late final TextEditingController _instructionsController;

  // Localized label translation maps sent to the backend, aligned with the
  // segmented selector order (home / work / other). Each map mirrors the API
  // translation shape (`{'en': ..., 'ar': ...}`) so the label round-trips as a
  // localized value rather than a bare identifier.
  static const List<Map<String, String>> _labels = <Map<String, String>>[
    <String, String>{'en': 'Home', 'ar': 'المنزل'},
    <String, String>{'en': 'Work', 'ar': 'العمل'},
    <String, String>{'en': 'Other', 'ar': 'أخرى'},
  ];
  int _selectedLabelIndex = 0;

  /// Drives the Save button between its disabled and active states. Only the
  /// required fields (phone / floor / building) feed it.
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Prefill from the existing address when editing. The floor field maps to
    // building_number and the building field maps to floor — the same swap the
    // save payload applies, mirrored here so a round-trip stays consistent.
    _phoneController = TextEditingController(
      text: widget.isEditScreen ? widget.address.phone : null,
    );
    _floorNumberController = TextEditingController(
      text: widget.isEditScreen ? widget.address.buildingNumber : null,
    );
    _buildingNameController = TextEditingController(
      text: widget.isEditScreen ? widget.address.floor : null,
    );
    _apartmentController = TextEditingController(
      text: widget.isEditScreen ? widget.address.apartment : null,
    );
    _instructionsController = TextEditingController(
      text: widget.isEditScreen ? widget.address.notes : null,
    );

    if (widget.isEditScreen) {
      // Restore the selected label by matching the stored English value against
      // our segment maps; fall back to the first segment (home) when the stored
      // label is missing or unrecognized.
      final String? storedLabel = widget.address.label?['en']?.toString();
      final int labelIndex = _labels.indexWhere(
        (Map<String, String> label) => label['en'] == storedLabel,
      );
      _selectedLabelIndex = labelIndex == -1 ? 0 : labelIndex;

      // An existing address was already validated when it was saved, so the
      // Save button starts enabled. Live validation still runs the moment any
      // required field changes (see [_onRequiredFieldChanged]).
      _isFormValid = true;
    }

    _phoneController.addListener(_onRequiredFieldChanged);
    _floorNumberController.addListener(_onRequiredFieldChanged);
    _buildingNameController.addListener(_onRequiredFieldChanged);
  }

  void _onRequiredFieldChanged() {
    final bool isValid =
        AppValidator.isValidSaudiPhone(_phoneController.text.trim()) &&
        _floorNumberController.text.trim().isNotEmpty &&
        _buildingNameController.text.trim().isNotEmpty;
    if (isValid != _isFormValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _floorNumberController.dispose();
    _buildingNameController.dispose();
    _apartmentController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    // The button is only active once [_isFormValid] is true, so no validation
    // is repeated here — just build the payload and submit.
    //
    // The floor field maps to building_number and the building field maps to
    // floor by product intent — keep that swap here at the boundary.
    final AddressModel address = widget.address.copyWith(
      phone: _phoneController.text.trim(),
      buildingNumber: _floorNumberController.text.trim(),
      floor: _buildingNameController.text.trim(),
      apartment: _apartmentController.text.trim(),
      notes: _instructionsController.text.trim(),
      label: _labels[_selectedLabelIndex],
    );

    if (widget.isEditScreen) {
      ref
          .read(editAddressProvider.notifier)
          .editAddress(addressId: widget.address.id ?? 0, address: address);
    } else {
      ref.read(addAddressProvider.notifier).addAddress(address: address);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final String? area = widget.address.area;

    // Both viewmodels expose the same AsyncValue<AddressModel?> shape, so the
    // screen watches/listens through one handle and only the submit call in
    // [_saveAddress] differs between add and edit.
    final ProviderListenable<AsyncValue<AddressModel?>> statusProvider =
        widget.isEditScreen ? editAddressProvider : addAddressProvider;

    ref.listen<AsyncValue<AddressModel?>>(statusProvider, (previous, next) {
      next.whenOrNull(
        data: (AddressModel? created) {
          if (created == null) return;
          // Return to the My Address screen. Pop this details screen, plus the
          // map underneath it when we came from there, so the map is removed
          // from the stack rather than left behind. Capture the router first —
          // context lookups are unsafe once the first page is popped.
          final GoRouter router = GoRouter.of(context);
          router.pop();
          if (widget.cameFromMap) router.pop();
        },
        error: (Object error, _) {
          ErrorSnackBar.show(context, error.toString());
        },
      );
    });

    final bool isSaving = ref.watch(statusProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWavedView(
        appBarTitle: widget.isEditScreen
            ? LangKeys.editAddress.tr()
            : LangKeys.addressDetails.tr(),
        body: SingleChildScrollView(
          child: Column(
            spacing: 10,
            children: [
              AreaSelector(
                value: (area == null || area.isEmpty)
                    ? LangKeys.failedToGetArea.tr()
                    : area,
                onChange: () {
                  // Coming from the map, just reveal it again; otherwise (edit
                  // from the address list) open a map to re-pick the location.
                  if (widget.cameFromMap) {
                    context.pop();
                  } else {
                    context.pushReplacementNamed(
                      AppRoutes.addNewAddressFromMapScreen,
                    );
                  }
                },
              ),
              AppSegmentedSelector(
                items: [
                  LangKeys.homeAddressSelector.tr(),
                  LangKeys.workAddressSelector.tr(),
                  LangKeys.otherKey.tr(),
                ],
                itemIcons: [
                  Assets.media.images.svg.homeSelected.svg(),
                  Assets.media.images.svg.workSelected.svg(),
                  Assets.media.images.svg.otherSelected.svg(),
                ],
                selectedColor: colors.primary,
                initialIndex: _selectedLabelIndex,
                onChanged: (int index) => _selectedLabelIndex = index,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  AddressField(
                    hintText: LangKeys.phoneNumber.tr(),
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d+\s-]')),
                      LengthLimitingTextInputFormatter(14),
                    ],
                  ),
                  AddressField(
                    hintText: LangKeys.floor.tr(),
                    controller: _floorNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  AddressField(
                    hintText: LangKeys.building.tr(),
                    controller: _buildingNameController,
                  ),
                  AddressField(
                    hintText: LangKeys.apartment.tr(),
                    controller: _apartmentController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  AddressField(
                    hintText: LangKeys.instructions.tr(),
                    controller: _instructionsController,
                  ),
                ],
              ),
              AspectRatio(
                aspectRatio: 7,
                child: !_isFormValid && !isSaving
                    ? PrimaryAppDisabledButton(
                        title: LangKeys.saveAddress.tr(),
                      )
                    : PrimaryAppButton(
                        title: LangKeys.saveAddress.tr(),
                        isLoading: isSaving,
                        onTap: _saveAddress,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}