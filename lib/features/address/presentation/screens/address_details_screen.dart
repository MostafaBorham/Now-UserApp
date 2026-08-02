import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_segmented_selector.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import '../../../settings/app_colors.dart';
import '../../../settings/components/primary_button.dart';
import '../widgets/address_field.dart';
import '../widgets/area_selector.dart';

class AddressDetailsScreen extends StatefulWidget {
  const AddressDetailsScreen({super.key, required this.placemark});

  final Placemark placemark;

  @override
  State<AddressDetailsScreen> createState() => _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends State<AddressDetailsScreen> {
  late final TextEditingController _floorNumberController;
  late final TextEditingController _buildingNameController;
  late final TextEditingController _instructionsController;

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
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Placemark placemark = widget.placemark;
    final String area = [
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
    ].whereType<String>().where((e) => e.isNotEmpty).join(' - ');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWavedView(
        appBarTitle: LangKeys.addressDetails.tr(),
        body: SingleChildScrollView(
          child: Column(
            spacing: 10,
            children: [
              AreaSelector(
                value: area.isEmpty
                    ? (placemark.name ?? LangKeys.failedToGetArea.tr())
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
              PrimaryButton(
                label: LangKeys.saveAddress.tr(),
                onPressed: _saveAddress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
