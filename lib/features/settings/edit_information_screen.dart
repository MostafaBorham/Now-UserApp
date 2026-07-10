import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

import 'app_colors.dart';
import 'components/edit_field.dart';
import 'components/gender_selector.dart';
import 'components/primary_button.dart';
import 'components/profile_avatar.dart';
import 'components/profile_header.dart';

/// Editable "Edit Information" screen, reached from the Edit button on the
/// Personal Information screen.
///
/// The form scrolls between a fixed header and a pinned "Save" bar.
class EditInformationScreen extends StatefulWidget {
  const EditInformationScreen({super.key});

  @override
  State<EditInformationScreen> createState() => _EditInformationScreenState();
}

class _EditInformationScreenState extends State<EditInformationScreen> {
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _nationality;

  DateTime? _dob;

  static const double _hPadding = 20;
  static const double _fieldGap = 18;
  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController(text: 'Guest 123');
    _phone = TextEditingController(text: '(239) 555-0108');
    _email = TextEditingController();
    _nationality = TextEditingController();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _email.dispose();
    _nationality.dispose();
    super.dispose();
  }

  String? get _dobText => _dob == null
      ? null
      : '${_months[_dob!.month - 1]} ${_dob!.day}, ${_dob!.year}';

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CommonHeader(
            title: 'Edit Information',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Center(
                    child: ProfileAvatar(size: 112, showCameraOverlay: true),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _hPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EditField(
                          label: 'Full Name',
                          controller: _fullName,
                          leadingAsset: Assets.media.images.svg.pen.path,
                          showCounter: true,
                          maxLength: 40,
                        ),
                        const SizedBox(height: _fieldGap),
                        EditField(
                          label: 'Phone',
                          controller: _phone,
                          leadingAsset: Assets.media.images.svg.pen.path,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: _fieldGap),
                        EditField(
                          label: 'Email',
                          controller: _email,
                          hintText: 'Enter email address',
                          leadingAsset: Assets.media.images.svg.pen.path,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: _fieldGap),
                        const Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.fieldLabel,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CommonScreenTabs(
                          height: 49,
                          tabsName: ["Male", "Female"],
                          activeFontColor: Colors.white,
                          inactiveFontColor: AppColors.textPrimary,
                          onTaptab: (currentTab) {},
                          radius: 100,
                          tapRadius: 100,
                        ),
                        const SizedBox(height: _fieldGap),
                        EditField(
                          label: 'Date of Birth',
                          hintText: 'Select Date of Birth',
                          valueText: _dobText,
                          trailingAsset: Assets.media.images.svg.date.path,
                          readOnly: true,
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: _fieldGap),
                        EditField(
                          label: 'Nationality',
                          controller: _nationality,
                          hintText: 'Enter your nationality',
                          trailingAsset: Assets.media.images.svg.pen.path,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _SaveBar(onSave: () => context.pop()),
        ],
      ),
    );
  }
}

/// Pinned bottom bar holding the green "Save" button.
class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: PrimaryButton(label: 'Save', onPressed: onSave),
        ),
      ),
    );
  }
}
