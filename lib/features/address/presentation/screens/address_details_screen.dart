import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_segmented_selector.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/add_address_vm.dart';
import '../../../settings/app_colors.dart';
import '../widgets/address_field.dart';
import '../widgets/area_selector.dart';

class AddressDetailsScreen extends ConsumerStatefulWidget {
  const AddressDetailsScreen({
    super.key,
    required this.address,
    this.cameFromMap = false,
  });

  final AddressModel address;

  /// True when this screen was pushed from the map, which is therefore still
  /// in the stack — "Change" pops back to it instead of opening a new map.
  final bool cameFromMap;

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

  // Stable label identifiers sent to the backend, aligned with the segmented
  // selector order (home / work / other).
  static const List<String> _labels = <String>['home', 'work', 'other'];
  int _selectedLabelIndex = 0;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _floorNumberController = TextEditingController();
    _buildingNameController = TextEditingController();
    _apartmentController = TextEditingController();
    _instructionsController = TextEditingController();
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
    final String phone = _phoneController.text.trim();
    final bool isPhoneEmpty = phone.isEmpty;
    final bool isFloorEmpty = _floorNumberController.text.trim().isEmpty;
    final bool isBuildingEmpty = _buildingNameController.text.trim().isEmpty;
    if (isPhoneEmpty || isFloorEmpty || isBuildingEmpty) {
      ErrorSnackBar.show(context, LangKeys.completeAddressInfo);
      return;
    }

    // Egyptian mobile numbers: 11 digits starting with 01.
    final bool isPhoneValid = RegExp(r'^01[0-9]{9}$').hasMatch(phone);
    if (!isPhoneValid) {
      ErrorSnackBar.show(context, LangKeys.invalidPhone);
      return;
    }

    // The floor field maps to building_number and the building field maps to
    // floor by product intent — keep that swap here at the boundary.
    final AddressModel address = widget.address.copyWith(
      phone: phone,
      buildingNumber: _floorNumberController.text.trim(),
      floor: _buildingNameController.text.trim(),
      apartment: _apartmentController.text.trim(),
      notes: _instructionsController.text.trim(),
      label: _labels[_selectedLabelIndex],
    );

    ref.read(addAddressProvider.notifier).addAddress(address: address);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String? area = widget.address.area;

    ref.listen<AsyncValue<AddressModel?>>(addAddressProvider, (previous, next) {
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

    final bool isSaving = ref.watch(addAddressProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWavedView(
        appBarTitle: LangKeys.addressDetails.tr(),
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
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
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
                child: PrimaryAppButton(
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