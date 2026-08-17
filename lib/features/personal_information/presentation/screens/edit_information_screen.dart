import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/update_profile_vm.dart';

import '../widgets/edit_field.dart';
import '../widgets/gender_selector.dart';
import '../widgets/primary_button.dart';
import '../widgets/profile_avatar.dart';

/// Editable "Edit Information" screen, reached from the Edit button on the
/// Personal Information screen.
///
/// Prefilled once from the already-loaded [getProfileProvider] data. Saving
/// sends the editable fields via [updateProfileProvider] (PUT + JSON, or POST +
/// multipart when the avatar changed); on success it pops (the read screen
/// refreshes itself). Phone is read-only (it is the OTP identity).
class EditInformationScreen extends ConsumerStatefulWidget {
  const EditInformationScreen({super.key});

  @override
  ConsumerState<EditInformationScreen> createState() =>
      _EditInformationScreenState();
}

class _EditInformationScreenState extends ConsumerState<EditInformationScreen> {
  late final TextEditingController _fullName;
  late final TextEditingController _email;
  late final TextEditingController _nationality;

  String? _phone; // read-only display
  String? _gender; // 'male' | 'female' | original value if untouched
  DateTime? _dob;

  String? _currentAvatarUrl; // existing remote avatar, shown until changed
  File? _pickedAvatar; // newly picked file to upload
  bool _removeAvatar = false; // user chose to clear the picture

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
    // Prefill once from the profile the read screen already loaded.
    final data = ref.read(getProfileProvider).valueOrNull;
    final ProfileModel? p = data?.profile;
    _fullName = TextEditingController(text: p?.fullName ?? '');
    _email = TextEditingController(text: p?.email ?? '');
    _nationality = TextEditingController(text: p?.nationality ?? '');
    _phone = p?.phone;
    _gender = p?.gender;
    _dob = p?.birthday == null ? null : DateTime.tryParse(p!.birthday!);
    _currentAvatarUrl = data?.avatarUrl;
  }

  @override
  void dispose() {
    _fullName.dispose();
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

  Future<void> _onAvatarTap() async {
    FocusScope.of(context).unfocus();
    final bool hasAvatar = _pickedAvatar != null ||
        (!_removeAvatar && (_currentAvatarUrl?.isNotEmpty ?? false));

    final _AvatarAction? action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, _AvatarAction.pick),
            ),
            if (hasAvatar)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove photo'),
                onTap: () => Navigator.pop(sheetContext, _AvatarAction.remove),
              ),
          ],
        ),
      ),
    );

    if (action == _AvatarAction.pick) {
      await _pickAvatar();
    } else if (action == _AvatarAction.remove) {
      setState(() {
        _pickedAvatar = null;
        _removeAvatar = true;
      });
    }
  }

  Future<void> _pickAvatar() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _pickedAvatar = File(picked.path);
        _removeAvatar = false;
      });
    }
  }

  String? _clean(String text) {
    final String trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// DateTime → 'YYYY-MM-DD' for the API.
  String _apiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    final ProfileModel edited = ProfileModel(
      fullName: _clean(_fullName.text),
      email: _clean(_email.text),
      gender: _gender,
      birthday: _dob == null ? null : _apiDate(_dob!),
      nationality: _clean(_nationality.text),
    );

    final bool ok = await ref.read(updateProfileProvider.notifier).save(
          edited,
          avatar: _pickedAvatar,
          removeAvatar: _removeAvatar,
        );
    if (!mounted) return;

    if (ok) {
      context.pop();
    } else {
      final Object? error = ref.read(updateProfileProvider).error;
      ErrorSnackBar.show(
        context,
        error?.toString() ?? LangKeys.serverConnectionFailedKey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool saving = ref.watch(updateProfileProvider).isLoading;

    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.personalInformationKey.tr(),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: ProfileAvatar(
                        size: 112,
                        showCameraOverlay: true,
                        imageFile: _pickedAvatar,
                        imageUrl: (_pickedAvatar == null && !_removeAvatar)
                            ? _currentAvatarUrl
                            : null,
                        onCameraTap: _onAvatarTap,
                      ),
                    ),
                    const SizedBox(height: 28),
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
                      valueText: _phone,
                      hintText: '—',
                      readOnly: true,
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
                    Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.neutral500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CommonScreenTabs(
                      height: 49,
                      tabsName: const ["Male", "Female"],
                      initialIndex: _gender == 'female' ? 1 : 0,
                      activeFontColor: Colors.white,
                      inactiveFontColor: context.colors.tertiaryContainer,
                      onTaptab: (currentTab) =>
                          _gender = currentTab == 1 ? 'female' : 'male',
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
            ),
            _SaveBar(isLoading: saving, onSave: _save),
          ],
        ),
      ),
    );
  }
}

/// Pinned bottom bar holding the green "Save" button.
class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.onSave, required this.isLoading});

  final VoidCallback onSave;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.white,
        border: Border(top: BorderSide(color: context.colors.neutral200)),
      ),
      child: SafeArea(
        top: false,
        child: PrimaryButton(
          label: 'Save',
          isLoading: isLoading,
          onPressed: onSave,
        ),
      ),
    );
  }
}

/// Result of the avatar action sheet.
enum _AvatarAction { pick, remove }
