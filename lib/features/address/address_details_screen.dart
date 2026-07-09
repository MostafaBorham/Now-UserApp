import 'package:flutter/material.dart';

import '../settings/app_colors.dart';
import '../settings/components/gender_selector.dart';
import '../settings/components/primary_button.dart';
import '../settings/components/profile_header.dart';
import 'components/address_field.dart';
import 'components/area_selector.dart';

/// Address Details form — also serves as "Edit Address".
///
/// This is a single screen with several states: the selected address type
/// (Home / Work / Other) drives the two address-line placeholders, and
/// [isEditing] only swaps the header title. Tapping a tab re-renders the
/// placeholders live.
///
/// Sections (see `components/`):
///   1. [CommonHeader]     – yellow header + wave + back button + title.
///   2. [AreaSelector]      – selected delivery area + "Change".
///   3. [CommonScreenTabs]  – Home / Work / Other selector (shared widget,
///                            reused from the gender toggle).
///   4. [AddressField] × 3  – floor / building / instructions inputs.
///   5. [PrimaryButton]     – green "Save Address" (shared widget).
class AddressDetailsScreen extends StatefulWidget {
  const AddressDetailsScreen({
    super.key,
    this.isEditing = false,
    this.initialType = 0,
    this.area = 'Downtown - Tahrir',
  });

  /// When true the header reads "Edit Address" instead of "Address Details".
  final bool isEditing;

  /// Tab pre-selected on open: 0 = Home, 1 = Work, 2 = Other.
  final int initialType;

  /// Currently selected delivery area.
  final String area;

  @override
  State<AddressDetailsScreen> createState() => _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends State<AddressDetailsScreen> {
  /// Horizontal padding shared by every section.
  static const double _hPadding = 20;

  static const List<String> _tabs = ['Home', 'Work', 'Other'];
  static const List<String> _tabIcons = [
    'assets/svg/home_selected.svg',
    'assets/svg/work_selected.svg',
    'assets/svg/other_selected.svg',
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
    _type = widget.initialType;
    _line1 = TextEditingController();
    _line2 = TextEditingController();
    _instructions = TextEditingController();
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
      body: Column(
        children: [
          CommonHeader(
            title: widget.isEditing ? 'Edit Address' : 'Address Details',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(_hPadding, 20, _hPadding, 24),
              child: Column(
                children: [
                  AreaSelector(value: widget.area, onChange: () {}),
                  const SizedBox(height: 16),
                  CommonScreenTabs(
                    tabsName: _tabs,
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
                  AddressField(
                    hintText: _line1Hints[_type],
                    controller: _line1,
                  ),
                  const SizedBox(height: 14),
                  AddressField(
                    hintText: _line2Hints[_type],
                    controller: _line2,
                  ),
                  const SizedBox(height: 14),
                  AddressField(
                    hintText: 'instructions (optional)',
                    controller: _instructions,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Save Address',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
