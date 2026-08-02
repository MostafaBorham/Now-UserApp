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
import '../../../settings/components/primary_button.dart';
import '../widgets/address_field.dart';
import '../widgets/area_selector.dart';

class AddressDetailsScreen extends ConsumerStatefulWidget {
  const AddressDetailsScreen({super.key, required this.address});

  final AddressModel address;

  @override
  ConsumerState<AddressDetailsScreen> createState() =>
      _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends ConsumerState<AddressDetailsScreen> {
  late final TextEditingController _floorNumberController;
  late final TextEditingController _buildingNameController;
  late final TextEditingController _instructionsController;

  // Stable label identifiers sent to the backend, aligned with the segmented
  // selector order (home / work / other).
  static const List<String> _labels = <String>['home', 'work', 'other'];
  int _selectedLabelIndex = 0;

  @override
  void initState() {
    super.initState();
    _floorNumberController = TextEditingController();
    _buildingNameController = TextEditingController();
    _instructionsController = TextEditingController();
  }

  @override
  void dispose() {
    _floorNumberController.dispose();
    _buildingNameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    final bool isFloorEmpty = _floorNumberController.text.trim().isEmpty;
    final bool isBuildingEmpty = _buildingNameController.text.trim().isEmpty;
    if (isFloorEmpty || isBuildingEmpty) {
      ErrorSnackBar.show(context, LangKeys.completeAddressInfo);
      return;
    }

    // The floor field maps to building_number and the building field maps to
    // floor by product intent — keep that swap here at the boundary.
    final AddressModel address = widget.address.copyWith(
      buildingNumber: _floorNumberController.text.trim(),
      floor: _buildingNameController.text.trim(),
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
          if (created != null) context.pop();
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
                onChange: () => context.pushReplacementNamed(
                  AppRoutes.addNewAddressFromMapScreen,
                ),
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
