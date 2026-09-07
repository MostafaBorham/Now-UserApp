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

  // Drives the AppWavedView wave: it flattens while scrolled and springs back
  // to the curved edge once the list settles at the top.
  final ScrollController _scrollController = ScrollController();

  static const double _fieldGap = 18;

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
    _gender = _normalizeGender(p?.gender);
    _dob = p?.birthday == null ? null : DateTime.tryParse(p!.birthday!);
    _currentAvatarUrl = data?.avatarUrl;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _nationality.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Localized birthday label (e.g. "September 7, 2026" / Arabic equivalent).
  String? _dobText(BuildContext context) => _dob == null
      ? null
      : DateFormat.yMMMMd(context.locale.languageCode).format(_dob!);

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (BuildContext pickerContext, Widget? child) {
        final AppColorScheme colors = pickerContext.colors;
        final ThemeData base = Theme.of(pickerContext);
        return Theme(
          data: base.copyWith(
            colorScheme: base.colorScheme.copyWith(
              primary: colors.primary500Main, // selected-day circle + actions
              onPrimary: colors.white, // text on the selected day
              surface: colors.white, // calendar background
              onSurface: colors.black, // day numbers + header text
            ),
            dividerColor: colors.primary500Main, // divider under the header
            datePickerTheme: DatePickerThemeData(
              backgroundColor: colors.white,
              headerBackgroundColor: colors.white,
              headerForegroundColor: colors.black,
              dividerColor: colors.primary500Main,
            ),
          ),
          child: child!,
        );
      },
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
              title: Text(LangKeys.chooseFromGalleryKey.tr()),
              onTap: () => Navigator.pop(sheetContext, _AvatarAction.pick),
            ),
            if (hasAvatar)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(LangKeys.removePhotoKey.tr()),
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

  /// Wraps the phone number in a Unicode LTR isolate (LRI … PDI) so its digits
  /// and the leading country-code "+" always read left-to-right, while the
  /// field itself keeps aligning to the start side (hugging the leading icon)
  /// under both Arabic (RTL) and English (LTR).
  String? _ltrPhone(String? phone) {
    if (phone == null || phone.isEmpty) return null;
    // U+2066 LEFT-TO-RIGHT ISOLATE … U+2069 POP DIRECTIONAL ISOLATE.
    return '\u{2066}$phone\u{2069}';
  }

  /// Canonicalizes any incoming gender (English or Arabic, any case) to the
  /// English value the API expects, so we never send a localized label back
  /// even when the app is running in Arabic.
  String? _normalizeGender(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'male':
      case 'ذكر':
        return 'male';
      case 'female':
      case 'أنثى':
      case 'انثى':
        return 'female';
      default:
        return null;
    }
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
        appBarTitle: LangKeys.editInformationKey.tr(),
        scrollController: _scrollController,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                // Owns the top spacing AppWavedView drops when a scroll
                // controller is wired in, so it scrolls up with the content
                // and flattens the wave.
                padding: const EdgeInsets.only(top: 57, bottom: 24),
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
                    // Grey (neutral200) card sitting behind the whole form,
                    // matching the Figma design.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.neutral200.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EditField(
                            label: LangKeys.fullNameKey.tr(),
                            controller: _fullName,
                            leadingAsset: Assets.media.images.svg.pen.path,
                            showCounter: true,
                            maxLength: 40,
                          ),
                          const SizedBox(height: _fieldGap),
                          EditField(
                            label: LangKeys.phoneKey.tr(),
                            valueText: _ltrPhone(_phone),
                            hintText: '—',
                            leadingAsset: Assets.media.images.svg.pen.path,
                            readOnly: true,
                          ),
                          const SizedBox(height: _fieldGap),
                          EditField(
                            label: LangKeys.emailKey.tr(),
                            controller: _email,
                            hintText: LangKeys.enterEmailAddressKey.tr(),
                            leadingAsset: Assets.media.images.svg.pen.path,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: _fieldGap),
                          Text(
                            LangKeys.genderKey.tr(),
                            style: TextStyle(
                              fontSize: 13,
                              color: context.colors.neutral500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CommonScreenTabs(
                            height: 49,
                            tabsName: [
                              LangKeys.maleKey.tr(),
                              LangKeys.femaleKey.tr(),
                            ],
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
                            label: LangKeys.dateOfBirthKey.tr(),
                            hintText: LangKeys.selectDateOfBirthKey.tr(),
                            valueText: _dobText(context),
                            leadingAsset: Assets.media.images.svg.date.path,
                            readOnly: true,
                            onTap: _pickDate,
                          ),
                          const SizedBox(height: _fieldGap),
                          EditField(
                            label: LangKeys.nationalityKey.tr(),
                            controller: _nationality,
                            hintText: LangKeys.enterNationalityKey.tr(),
                            leadingAsset: Assets.media.images.svg.pen.path,
                          ),
                        ],
                      ),
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
          label: LangKeys.saveKey.tr(),
          isLoading: isLoading,
          onPressed: onSave,
        ),
      ),
    );
  }
}

/// Result of the avatar action sheet.
enum _AvatarAction { pick, remove }
