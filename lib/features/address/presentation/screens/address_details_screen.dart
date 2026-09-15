import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/dialogs/app_custom_alert_dialog.dart';
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



  final bool cameFromMap;




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





  static const List<List<String>> _fieldHints = <List<String>>[
    <String>[LangKeys.floor, LangKeys.apartment],
    <String>[LangKeys.floorWork, LangKeys.floorNumberOptional],
    <String>[LangKeys.floor, LangKeys.apartment],
  ];




  static const String _phonePrefix = '05';

  int _selectedLabelIndex = 0;





  late final List<String> _baselineFields;
  late final int _baselineLabelIndex;




  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();







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



      final String? storedLabel = widget.address.label?['en']?.toString();
      final int labelIndex = AddressModel.labelOptions.indexWhere(
        (Map<String, String> label) => label['en'] == storedLabel,
      );
      _selectedLabelIndex = labelIndex == -1 ? 0 : labelIndex;
    }




    _isFormValid = _isRequiredFieldsFilled();

    _baselineFields = _fieldValues();
    _baselineLabelIndex = _selectedLabelIndex;

    _phoneController.addListener(_onRequiredFieldChanged);
    _floorNumberController.addListener(_onRequiredFieldChanged);
    _buildingNameController.addListener(_onRequiredFieldChanged);
  }



  List<String> _fieldValues() => <String>[
    _phoneController.text,
    _floorNumberController.text,
    _apartmentController.text,
    _buildingNameController.text,
    _instructionsController.text,
  ];


  bool get _hasUnsavedChanges =>
      _selectedLabelIndex != _baselineLabelIndex ||
      !listEquals(_fieldValues(), _baselineFields);


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



  bool _isRequiredFieldsFilled() {
    return (_phoneController.text.isEmpty || _composedPhone() != null) &&
        _floorNumberController.text.trim().isNotEmpty &&
        _buildingNameController.text.trim().isNotEmpty;
  }




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




    final ProviderListenable<AsyncValue<AddressModel?>> statusProvider =
        widget.isEditScreen ? editAddressProvider : addAddressProvider;

    ref.listen<AsyncValue<AddressModel?>>(statusProvider, (previous, next) {
      next.whenOrNull(
        data: (AddressModel? created) {
          if (created == null) return;




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


            padding: const EdgeInsets.only(top: 57),
            child: Column(
              spacing: 16,
              children: [
                AreaSelector(
                  value: (area == null || area.isEmpty)
                      ? LangKeys.failedToGetArea.tr()
                      : area,
                  onChange: () async {






                    if (_hasUnsavedChanges && !await _confirmDiscard()) return;
                    if (!context.mounted) return;



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



                    LengthLimitingTextInputFormatter(12),
                  ],
                ),
                !_isFormValid && !isSaving


                    ? GestureDetector(
                        onTap: () => AppToast.showError(
                          context,



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
      ),
    );
  }
}
