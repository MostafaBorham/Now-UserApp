import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_segmented_selector.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/app_validator.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/add_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/edit_address_vm.dart';
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
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _phoneController;
  late final TextEditingController _floorNumberController;
  late final TextEditingController _apartmentController;
  late final TextEditingController _buildingNameController;
  late final TextEditingController _instructionsController;

  /// Placeholders for the first two fields, per selected label. A work address
  /// asks for a company name and a floor number where home and "other" ask for
  /// a floor/villa and an apartment — the values they collect stay the same,
  /// only the wording changes. Home and "other" read identically.
  static const List<List<String>> _fieldHints = <List<String>>[
    <String>[LangKeys.floor, LangKeys.apartment],
    <String>[LangKeys.floorWork, LangKeys.floorNumberOptional],
    <String>[LangKeys.floor, LangKeys.apartment],
  ];

  /// Shown before the phone input and prepended to whatever is typed. Saudi
  /// mobile numbers are the only ones this form collects, so the head of every
  /// number is fixed and the field holds just the 8 digits that follow it.
  static const String _phonePrefix = '05';

  int _selectedLabelIndex = 0;

  /// Drives the Save button between its disabled and active states. Only the
  /// required fields (floor / building) feed it; the phone is optional but
  /// must still be well-formed once something is typed into it.
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Prefill from the existing address when editing. The floor field maps to
    // building_number and the building field maps to floor — the same swap the
    // save payload applies, mirrored here so a round-trip stays consistent.
    // The phone field holds only the digits after [_phonePrefix], so a stored
    // number is reduced to that tail — whichever format it was saved in. One
    // that isn't a Saudi mobile leaves the field empty rather than prefilling a
    // value the form would reject, which used to freeze the Save button.
    _phoneController = TextEditingController(
      text: widget.isEditScreen
          ? AppValidator.saudiLocalPhoneTail(widget.address.phone)
          : null,
    );
    _floorNumberController = TextEditingController(
      text: widget.isEditScreen ? widget.address.buildingNumber : null,
    );
    _apartmentController = TextEditingController(
      text: widget.isEditScreen ? widget.address.apartment : null,
    );
    _buildingNameController = TextEditingController(
      text: widget.isEditScreen ? widget.address.floor : null,
    );
    _instructionsController = TextEditingController(
      text: widget.isEditScreen ? widget.address.notes : null,
    );

    if (widget.isEditScreen) {
      // Restore the selected label by matching the stored English value against
      // our segment maps; fall back to the first segment (home) when the stored
      // label is missing or unrecognized.
      final String? storedLabel = widget.address.label?['en']?.toString();
      final int labelIndex = AddressModel.labelOptions.indexWhere(
        (Map<String, String> label) => label['en'] == storedLabel,
      );
      _selectedLabelIndex = labelIndex == -1 ? 0 : labelIndex;
    }

    // Run the same check the listeners run, over whatever the prefill put in
    // the fields: an existing address usually enables Save straight away, but
    // one stored without a floor or building must not submit those blanks.
    _isFormValid = _isRequiredFieldsFilled();

    _phoneController.addListener(_onRequiredFieldChanged);
    _floorNumberController.addListener(_onRequiredFieldChanged);
    _buildingNameController.addListener(_onRequiredFieldChanged);
  }

  /// The Save button's condition: both required fields filled, and the phone
  /// either left empty or well-formed.
  bool _isRequiredFieldsFilled() {
    return (_phoneController.text.isEmpty || _composedPhone() != null) &&
        _floorNumberController.text.trim().isNotEmpty &&
        _buildingNameController.text.trim().isNotEmpty;
  }

  /// The full number to submit, or null when the field is empty or holds
  /// something that can't be a Saudi mobile. The Save button and the payload
  /// both go through this, so what is validated is always what is sent.
  String? _composedPhone() {
    final String? tail = AppValidator.saudiLocalPhoneTail(
      _phoneController.text,
    );
    return tail == null ? null : '$_phonePrefix$tail';
  }

  void _onRequiredFieldChanged() {
    final bool isValid = _isRequiredFieldsFilled();
    if (isValid != _isFormValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _phoneController.dispose();
    _floorNumberController.dispose();
    _apartmentController.dispose();
    _buildingNameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    // The button is only active once [_isFormValid] is true, so no validation
    // is repeated here — just build the payload and submit.
    //
    // The floor field maps to building_number and the building field maps to
    // floor by product intent — keep that swap here at the boundary.
    // A null phone (field left empty) falls back to the stored one, which keeps
    // an edit from sending a blank the backend rejects — `addresses.phone` is
    // NOT NULL, so a phone can never be cleared from here.
    final AddressModel address = widget.address.copyWith(
      phone: _composedPhone(),
      buildingNumber: _floorNumberController.text.trim(),
      apartment: _apartmentController.text.trim(),
      floor: _buildingNameController.text.trim(),
      notes: _instructionsController.text.trim(),
      label: AddressModel.labelOptions[_selectedLabelIndex],
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
    final List<String> hints = _fieldHints[_selectedLabelIndex];

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
          AppToast.showError(context, error.toString());
        },
      );
    });

    final bool isSaving = ref.watch(statusProvider).isLoading;

    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: widget.isEditScreen
            ? LangKeys.editAddress.tr()
            : LangKeys.addressDetails.tr(),
        scrollController: _scrollController,
        body: SingleChildScrollView(
          controller: _scrollController,
          // Owns the top spacing AppWavedView drops when a scroll controller is
          // wired in, so it scrolls up with the content and flattens the wave.
          padding: const EdgeInsets.only(top: 57),
          child: Column(
            spacing: 16,
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
                      extra: widget.address,
                    );
                  }
                },
              ),
              AppSegmentedSelector(
                items: [
                  LangKeys.homeAddressSelector.tr(),
                  LangKeys.workAddressSelector.tr(),
                  LangKeys.otherAddressSelector.tr(),
                ],
                itemIcons: [
                  Assets.media.images.svg.homeSelected.svg(),
                  Assets.media.images.svg.workSelected.svg(),
                  Assets.media.images.svg.otherSelected.svg(),
                ],
                selectedColor: colors.primary500Main,
                // 4px track padding around a 44px pill, per the design.
                height: 52,
                initialIndex: _selectedLabelIndex,
                onChanged: (int index) =>
                    setState(() => _selectedLabelIndex = index),
              ),
              AddressField(
                hintText: hints[0].tr(),
                controller: _floorNumberController,
              ),
              AddressField(
                hintText: hints[1].tr(),
                controller: _apartmentController,
              ),
              AddressField(
                hintText: LangKeys.building.tr(),
                controller: _buildingNameController,
              ),
              AddressField(
                hintText: LangKeys.instructions.tr(),
                controller: _instructionsController,
              ),
              AddressField(
                hintText: LangKeys.phoneNumberOptional.tr(),
                prefixText: _phonePrefix,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  // Room for a number pasted or typed in full (12 digits for
                  // `+966…`); it is reduced to the 8-digit tail on save rather
                  // than being truncated to something valid but wrong.
                  LengthLimitingTextInputFormatter(12),
                ],
              ),
              !_isFormValid && !isSaving
                  // Tappable while disabled, so the button can say why instead
                  // of just refusing to react.
                  ? GestureDetector(
                      onTap: () => AppToast.showError(
                        context,
                        // Say which field is wrong: a half-typed phone blocks
                        // Save too, and "complete the address info" points at
                        // the wrong part of the form.
                        _phoneController.text.isNotEmpty &&
                                _composedPhone() == null
                            ? LangKeys.enterValidMobileNumber
                            : LangKeys.completeAddressInfo,
                      ),
                      child: PrimaryAppDisabledButton(
                        title: LangKeys.saveAddress.tr(),
                      ),
                    )
                  : PrimaryAppButton(
                      title: LangKeys.saveAddress.tr(),
                      isLoading: isSaving,
                      onTap: _saveAddress,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
