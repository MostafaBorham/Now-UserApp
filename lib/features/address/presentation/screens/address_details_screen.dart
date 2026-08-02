import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/app_tab_bar.dart';
import '../../../settings/app_colors.dart';
import '../../../settings/components/gender_selector.dart';
import '../../../settings/components/primary_button.dart';
import '../../data/models/address_model.dart';
import '../widgets/address_field.dart';
import '../widgets/area_selector.dart';

class AddressDetailsScreen extends StatefulWidget {
  const AddressDetailsScreen({super.key, this.selectedLocation});

  final LatLng? selectedLocation;

  @override
  State<AddressDetailsScreen> createState() => _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends State<AddressDetailsScreen> {
  late final TextEditingController _homeFloorNumberController;
  late final TextEditingController _homeBuildingNameController;
  late final TextEditingController _homeInstructionsController;
  late final TextEditingController _workFloorNumberController;
  late final TextEditingController _workBuildingNameController;
  late final TextEditingController _workInstructionsController;
  late final TextEditingController _otherFloorNumberController;
  late final TextEditingController _otherBuildingNameController;
  late final TextEditingController _otherInstructionsController;

  @override
  void initState() {
    super.initState();
    _homeFloorNumberController = TextEditingController();
    _homeBuildingNameController = TextEditingController();
    _homeInstructionsController = TextEditingController();
    _workFloorNumberController = TextEditingController();
    _workBuildingNameController = TextEditingController();
    _workInstructionsController = TextEditingController();
    _otherFloorNumberController = TextEditingController();
    _otherBuildingNameController = TextEditingController();
    _otherInstructionsController = TextEditingController();
  }

  Future<void> _resolveAreaFromLocation(LatLng location) async {
    try {
      await setLocaleIdentifier(context.locale.toLanguageTag());
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (!mounted) return;
      final Placemark? p = placemarks.isNotEmpty ? placemarks.first : null;
      final String? area = _formatArea(p);
      print(area);
    } catch (e, s) {
      print('catch = $e');
      print('$s');
      if (!mounted) return;
    }
  }

  String? _formatArea(Placemark? p) {
    if (p == null) return null;
    final List<String> parts = <String>[
      p.subLocality ?? '',
      p.locality ?? '',
      p.administrativeArea ?? '',
    ].where((String s) => s.trim().isNotEmpty).toList();
    // Deduplicate consecutive equal parts (some OSes repeat locality).
    final List<String> unique = <String>[];
    for (final String part in parts) {
      if (unique.isEmpty || unique.last != part) unique.add(part);
    }
    if (unique.isEmpty) return null;
    return unique.take(2).join(' - ');
  }

  @override
  void dispose() {
    _homeFloorNumberController.dispose();
    _homeBuildingNameController.dispose();
    _homeInstructionsController.dispose();
    _workFloorNumberController.dispose();
    _workBuildingNameController.dispose();
    _workInstructionsController.dispose();
    _otherFloorNumberController.dispose();
    _otherBuildingNameController.dispose();
    _otherInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWavedView(
        appBarTitle: LangKeys.addressDetails.tr(),
        body: Column(
          spacing: 10,
          children: [
            AreaSelector(value: '', onChange: () {}),
            Flexible(
              child: AppTabBar(
                tabs: [LangKeys.homeKey.tr(), 'Work', LangKeys.otherKey.tr()],
                tabIcons: [
                  Assets.media.images.svg.homeSelected.svg(),
                  Assets.media.images.svg.workSelected.svg(),
                  Assets.media.images.svg.otherSelected.svg(),
                ],
                views: [
                  SingleChildScrollView(
                    child: Column(
                      spacing: 16,
                      children: [
                        AddressField(
                          hintText: LangKeys.floor.tr(),
                          controller: _homeFloorNumberController,
                        ),
                        AddressField(
                          hintText: LangKeys.building.tr(),
                          controller: _homeBuildingNameController,
                        ),
                        AddressField(
                          hintText: LangKeys.instructions.tr(),
                          controller: _homeInstructionsController,
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      spacing: 16,
                      children: [
                        AddressField(
                          hintText: LangKeys.floor.tr(),
                          controller: _workFloorNumberController,
                        ),
                        AddressField(
                          hintText: LangKeys.building.tr(),
                          controller: _workBuildingNameController,
                        ),
                        AddressField(
                          hintText: LangKeys.instructions.tr(),
                          controller: _workInstructionsController,
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      spacing: 16,
                      children: [
                        AddressField(
                          hintText: LangKeys.floor.tr(),
                          controller: _otherFloorNumberController,
                        ),
                        AddressField(
                          hintText: LangKeys.building.tr(),
                          controller: _otherBuildingNameController,
                        ),
                        AddressField(
                          hintText: LangKeys.instructions.tr(),
                          controller: _otherInstructionsController,
                        ),
                      ],
                    ),
                  ),
                ],
                selectedTabColor: colors.primary,
              ),
            ),
            PrimaryButton(
              label: LangKeys.saveAddress.tr(),
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
