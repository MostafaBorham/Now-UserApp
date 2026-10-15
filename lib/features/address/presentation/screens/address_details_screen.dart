import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/formatters/saudi_phone_input_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/dialogs/app_custom_alert_dialog.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_segmented_selector.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/app_validator.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/add_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/edit_address_vm.dart';
import '../widgets/address_field.dart';
import '../widgets/area_selector.dart';
import '../widgets/set_default_address_checkbox.dart';

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
  /// a floor/villa and an apartment — see [_isWork] for where each is saved.
  /// Home and "other" read identically.
  static const List<List<String>> _fieldHints = <List<String>>[
    <String>[LangKeys.floor, LangKeys.apartment],
    <String>[LangKeys.floorWork, LangKeys.floorNumberOptional],
    <String>[LangKeys.floor, LangKeys.apartment],
  ];

  /// Emoji, with the joiners and modifiers that build them. Text fields reach
  /// the courier, and the backend checks only their length.
  static final TextInputFormatter _noEmoji = FilteringTextInputFormatter.deny(
    RegExp(
      // The lint's own parser lacks two of these properties; the VM has them
      // (the screen's test types emoji through this).
      // ignore: valid_regexps
      r'[\p{Extended_Pictographic}\p{Emoji_Modifier}\p{Regional_Indicator}\u{FE0F}\u{200D}\u{20E3}]',
      unicode: true,
    ),
  );

  /// The free-text fields (building, and Work's company name) within the
  /// backend's own `max:50`, and the notes within its `max:1000`. Past them a
  /// save is a 422.
  static final List<TextInputFormatter> _columnLimit = <TextInputFormatter>[
    _noEmoji,
    LengthLimitingTextInputFormatter(50),
  ];
  static final List<TextInputFormatter> _notesLimit = <TextInputFormatter>[
    _noEmoji,
    LengthLimitingTextInputFormatter(1000),
  ];

  /// The number fields, by hint, so each gets a number keyboard, rejects
  /// letters and stays within a real length: a floor or villa number fits in
  /// 4 digits, an apartment in 5. The backend allows 50 characters on each.
  /// `floorWork` ("Company Name") and `building` are text.
  static final Map<String, List<TextInputFormatter>> _numericLimits =
      <String, List<TextInputFormatter>>{
        LangKeys.floor: _digits(4),
        LangKeys.floorNumberOptional: _digits(4),
        LangKeys.apartment: _digits(5),
      };

  static List<TextInputFormatter> _digits(int max) => <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(max),
  ];

  int _selectedLabelIndex = 0;

  /// The form exactly as [initState] prefilled it, so back can tell an
  /// untouched form from an edited one. Captured from the controllers after the
  /// prefill rather than rebuilt from [widget.address], so the comparison can
  /// never drift from what was actually put in the fields.
  late List<String> _baselineFields;
  late int _baselineLabelIndex;
  late bool _baselineIsDefaultAddress;

  /// The checkbox value sent as `is_default` in the create/update payload.
  bool _isDefaultAddress = false;

  /// Drives the Save button between its disabled and active states. Only the
  /// required fields (floor / building) feed it; the phone is optional but
  /// must still be well-formed once something is typed into it.
  bool _isFormValid = false;

  /// Work asks for its first two fields the other way round: the company
  /// (saved as the unit, `apartment`) and then the floor, where home and
  /// "other" ask for the floor and then the apartment. Every field is saved to
  /// the column it names — the server builds `full_address`, and the courier's
  /// copy of the address, from those columns.
  bool get _isWork => _selectedLabelIndex == 1;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _floorNumberController = TextEditingController();
    _apartmentController = TextEditingController();
    _buildingNameController = TextEditingController();
    _instructionsController = TextEditingController();

    _applyWidgetState();

    _phoneController.addListener(_onRequiredFieldChanged);
    _floorNumberController.addListener(_onRequiredFieldChanged);
    _buildingNameController.addListener(_onRequiredFieldChanged);
    for (final TextEditingController controller in <TextEditingController>[
      _phoneController,
      _floorNumberController,
      _apartmentController,
      _buildingNameController,
      _instructionsController,
    ]) {
      controller.addListener(_onAnyFieldChanged);
    }
  }

  /// Whether the form's text differed from the stored address at the last
  /// rebuild; rebuilds only when that flips, not on every keystroke.
  bool _wasEdited = false;

  void _onAnyFieldChanged() {
    final bool edited = _hasUnsavedChanges;
    if (edited != _wasEdited) {
      _wasEdited = edited;
      setState(() {});
    }
  }

  /// Editing an address and changing nothing has nothing to save, so Save
  /// waits for a change there. A new address has no such baseline.
  bool get _isUnchangedEdit => widget.isEditScreen && !_hasUnsavedChanges;

  @override
  void didUpdateWidget(covariant AddressDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address ||
        oldWidget.isEditScreen != widget.isEditScreen) {
      _applyWidgetState();
    }
  }

  /// Every text field's current value, in a fixed order, for comparing the form
  /// against [_baselineFields].
  List<String> _fieldValues() => <String>[
    _phoneController.text,
    _floorNumberController.text,
    _apartmentController.text,
    _buildingNameController.text,
    _instructionsController.text,
  ];

  /// Whether anything the user typed or picked would be lost by leaving.
  bool get _hasUnsavedChanges =>
      _selectedLabelIndex != _baselineLabelIndex ||
      _isDefaultAddress != _baselineIsDefaultAddress ||
      !listEquals(_fieldValues(), _baselineFields);

  /// Rebuilds the form state from the current widget input, covering both
  /// first build and updates to a different add/edit payload on the same route.
  void _applyWidgetState() {
    if (widget.isEditScreen) {
      // Restore the selected label by matching the stored English value against
      // our segment maps; fall back to the first segment (home) when the stored
      // label is missing or unrecognized. First, because [_isWork] decides
      // which column the first two fields prefill from.
      final String? storedLabel = widget.address.label?['en']?.toString();
      final int labelIndex = AddressModel.labelOptions.indexWhere(
        (Map<String, String> label) => label['en'] == storedLabel,
      );
      _selectedLabelIndex = labelIndex == -1 ? 0 : labelIndex;
    } else {
      _selectedLabelIndex = 0;
    }

    // Prefill from the existing address when editing. The phone field shows a
    // number the way the login field does (`(05) 1234-5678`), so a stored
    // number is reduced to its 8-digit tail — whichever format it was saved
    // in. One that isn't a Saudi mobile leaves the field empty rather than
    // prefilling a value the form would reject, which used to freeze Save.
    final AddressModel? stored = widget.isEditScreen ? widget.address : null;
    _isDefaultAddress = stored?.isDefault ?? false;
    _phoneController.text = SaudiPhoneInputFormatter.format(
      AppValidator.saudiLocalPhoneTail(stored?.phone),
    );
    _floorNumberController.text = _isWork
        ? stored?.apartment ?? ''
        : stored?.floor ?? '';
    _apartmentController.text = _isWork
        ? stored?.floor ?? ''
        : stored?.apartment ?? '';
    _buildingNameController.text = stored?.buildingNumber ?? '';
    _instructionsController.text = stored?.notes ?? '';

    // Run the same check the listeners run, over whatever the prefill put in
    // the fields: an existing address usually enables Save straight away, but
    // one stored without a floor or building must not submit those blanks.
    _isFormValid = _isRequiredFieldsFilled();

    _baselineFields = _fieldValues();
    _baselineLabelIndex = _selectedLabelIndex;
    _baselineIsDefaultAddress = _isDefaultAddress;
  }

  /// Asks before throwing the form away. Returns true when the user confirms.
  Future<bool> _confirmDiscard() async {
    bool discard = false;
    await AppCustomAlertDialog.show(
      context,
      (BuildContext dialogContext) => AppCustomAlertDialog(
        title: LangKeys.discardChangesKey.tr(),
        message: LangKeys.discardChangesMessageKey.tr(),
        confirmLabel: LangKeys.discardKey.tr(),
        onConfirm: () {
          discard = true;
          Navigator.of(dialogContext).pop();
        },
      ),
    );
    return discard;
  }

  /// The Save button's condition: both required fields filled, and the phone
  /// either left empty or well-formed.
  bool _isRequiredFieldsFilled() {
    return (_phoneController.text.isEmpty || _composedPhone() != null) &&
        _floorNumberController.text.trim().isNotEmpty &&
        _buildingNameController.text.trim().isNotEmpty;
  }

  /// The full number to submit, or null until all 8 digits after the field's
  /// `(05)` head are there. The Save button and the payload both go through
  /// this, so what is validated is always what is sent — and the field shows
  /// exactly that number. The generic tail parser used to accept `05` plus 7
  /// digits here and save a different number (`051234567` → `0551234567`).
  String? _composedPhone() {
    final String text = _phoneController.text;
    return SaudiPhoneInputFormatter.isComplete(text)
        ? '05${phoneFieldSignificantDigits(text)}'
        : null;
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
    // A null phone (field left empty) keeps the stored one: `copyWith` ignores
    // null, and the update endpoint drops nulls anyway, so a phone cannot be
    // cleared from here.
    final AddressModel address = widget.address.copyWith(
      phone: _composedPhone(),
      floor: (_isWork ? _apartmentController : _floorNumberController).text
          .trim(),
      apartment: (_isWork ? _floorNumberController : _apartmentController).text
          .trim(),
      buildingNumber: _buildingNameController.text.trim(),
      notes: _instructionsController.text.trim(),
      label: AddressModel.labelOptions[_selectedLabelIndex],
      isDefault: _isDefaultAddress,
    );

    if (widget.isEditScreen) {
      ref
          .read(editAddressProvider.notifier)
          .editAddress(addressId: widget.address.id, address: address);
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

    return PopScope(
      // Always false, never `!_hasUnsavedChanges`: `canPop` is read at build
      // time, and typing in a field does not rebuild, so a computed value would
      // answer with whatever was true when the form was last painted. Deciding
      // inside the callback asks the question at the moment back is pressed.
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        if (!_hasUnsavedChanges) {
          context.pop();
          return;
        }
        final bool discard = await _confirmDiscard();
        if (!context.mounted) return;
        if (discard) context.pop();
      },
      child: Scaffold(
        backgroundColor: context.colors.white,
        body: AppWavedView(
          appBarTitle: widget.isEditScreen
              ? LangKeys.editAddress.tr()
              : LangKeys.addressDetails.tr(),
          scrollController: _scrollController,
          body: SingleChildScrollView(
            controller: _scrollController,
            // Owns the top spacing AppWavedView drops when a scroll controller is
            // wired in, so it scrolls up with the content.
            padding: const EdgeInsets.only(top: 57),
            child: Column(
              spacing: 16,
              children: [
                AreaSelector(
                  value: (area == null || area.isEmpty)
                      ? LangKeys.failedToGetArea.tr()
                      : area,
                  onChange: () async {
                    // Either branch leaves this screen and comes back to a freshly
                    // built form, so the typed values are gone either way — ask
                    // first, the same as pressing back. Neither `context.pop` nor
                    // `pushReplacementNamed` consults the `PopScope` below (only
                    // the system gesture and `Navigator.maybePop` do), so asking
                    // here does not double-prompt.
                    if (_hasUnsavedChanges && !await _confirmDiscard()) return;
                    if (!context.mounted) return;

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
                  label: hints[0].tr(),
                  controller: _floorNumberController,
                  keyboardType: _numericLimits.containsKey(hints[0])
                      ? TextInputType.number
                      : null,
                  inputFormatters: _numericLimits[hints[0]] ?? _columnLimit,
                ),
                AddressField(
                  label: hints[1].tr(),
                  controller: _apartmentController,
                  keyboardType: _numericLimits.containsKey(hints[1])
                      ? TextInputType.number
                      : null,
                  inputFormatters: _numericLimits[hints[1]] ?? _columnLimit,
                ),
                AddressField(
                  label: LangKeys.building.tr(),
                  controller: _buildingNameController,
                  inputFormatters: _columnLimit,
                ),
                AddressField(
                  label: LangKeys.instructions.tr(),
                  controller: _instructionsController,
                  inputFormatters: _notesLimit,
                ),
                AddressField(
                  label: LangKeys.phoneNumberOptional.tr(),
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  inputFormatters: const [SaudiPhoneInputFormatter()],
                ),
                SetDefaultAddressCheckbox(
                  value: _isDefaultAddress,
                  onChanged: isSaving
                      ? null
                      : (bool value) =>
                            setState(() => _isDefaultAddress = value),
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
                        child: PrimaryAppButton(
                          title: LangKeys.saveAddress.tr(),
                          isDisabled: true,
                        ),
                      )
                    : PrimaryAppButton(
                        title: LangKeys.saveAddress.tr(),
                        isLoading: isSaving,
                        isDisabled: _isUnchangedEdit && !isSaving,
                        onTap: _saveAddress,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
