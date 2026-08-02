import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import '../../../settings/app_colors.dart';
import '../../../settings/components/gender_selector.dart';
import '../../../settings/components/primary_button.dart';
import '../../data/models/address_model.dart';
import '../widgets/address_field.dart';
import '../widgets/area_selector.dart';

class AddressDetailsScreen extends StatefulWidget {
  const AddressDetailsScreen({
    super.key,
    this.address,
    this.selectedLocation,
    this.initialType = 0,
    this.area = 'Downtown - Tahrir',
  });

  /// The address being edited. When null the screen adds a new address;
  /// when provided the header reads "Edit Address" and the fields are
  /// pre-filled from it.
  final AddressModel? address;

  /// The map coordinate picked on the previous screen when adding a new
  /// address via the map flow. Null when editing an existing address.
  final LatLng? selectedLocation;

  /// Tab pre-selected on open: 0 = Home, 1 = Work, 2 = Other.
  final int initialType;

  /// Currently selected delivery area.
  final String area;

  /// Whether the screen is in edit mode (an existing address was passed).
  bool get isEditing => address != null;

  @override
  State<AddressDetailsScreen> createState() => _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends State<AddressDetailsScreen> {
  static const List<String> _tabs = ['Home', 'Work', 'Other'];
  static final List<String> _tabIcons = [
    Assets.media.images.svg.homeSelected.path,
    Assets.media.images.svg.workSelected.path,
    Assets.media.images.svg.otherSelected.path,
  ];

  /// First input placeholder per tab (Home / Work / Other).
  static const List<String> _line1Hints = [
    'Floor number / Villa number.',
    'Company Name / Floor Number',
    'Room / House / Floor Number',
  ];

  /// Second input placeholder per tab.
  static const List<String> _line2Hints = [
    'National address / Building name',
    'Building name',
    'National address / Building name',
  ];

  late final TextEditingController _line1;
  late final TextEditingController _line2;
  late final TextEditingController _instructions;

  late int _type;

  @override
  void initState() {
    super.initState();
    print('#selected address : ${widget.selectedLocation?.latitude}');
    final AddressModel? address = widget.address;
    _type = _tabIndexForLabel(address?.label) ?? widget.initialType;
    _line1 = TextEditingController(text: address?.floor ?? '');
    _line2 = TextEditingController(text: address?.buildingNumber ?? '');
    _instructions = TextEditingController(text: address?.notes ?? '');
  }


  int? _tabIndexForLabel(String? label) {
    if (label == null) return null;
    final int index = _tabs.indexWhere(
      (String tab) => tab.toLowerCase() == label.toLowerCase(),
    );
    return index == -1 ? null : index;
  }

  @override
  void dispose() {
    _line1.dispose();
    _line2.dispose();
    _instructions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWavedView(
        appBarTitle: widget.isEditing
            ? LangKeys.editAddress.tr()
            : LangKeys.addressDetails.tr(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              AreaSelector(
                value: widget.address?.area ?? widget.area,
                onChange: () {},
              ),
              const SizedBox(height: 16),
              CommonScreenTabs(
                tabsName: [
                  LangKeys.homeAddressSelector.tr(),
                  LangKeys.workAddressSelector.tr(),
                  LangKeys.otherAddressSelector.tr(),
                ],
                icons: _tabIcons,
                initialIndex: _type,
                height: 52,
                radius: 100,
                tapRadius: 100,
                backgroundColor: AppColors.grey,
                activeColor: AppColors.primaryGreen,
                activeFontColor: AppColors.buttonForeground,
                inactiveFontColor: AppColors.textPrimary,
                onTaptab: (index) => setState(() => _type = index),
              ),
              const SizedBox(height: 16),
              AddressField(hintText: LangKeys.floor.tr(), controller: _line1),
              const SizedBox(height: 14),
              AddressField(
                hintText: LangKeys.building.tr(),
                controller: _line2,
              ),
              const SizedBox(height: 14),
              AddressField(
                hintText: LangKeys.instructions.tr(),
                controller: _instructions,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: LangKeys.saveAddress.tr(),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}