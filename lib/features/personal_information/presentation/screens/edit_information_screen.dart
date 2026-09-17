import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nowdelivery_user_app/core/formatters/date_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/dialogs/app_custom_alert_dialog.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/utils/app_validator.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/personal_information_data.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/update_profile_vm.dart';

import '../widgets/edit_field.dart';
import '../widgets/gender_selector.dart';
import '../widgets/primary_button.dart';
import '../widgets/profile_avatar.dart';













class EditInformationScreen extends ConsumerStatefulWidget {
  const EditInformationScreen({super.key});

  @override
  ConsumerState<EditInformationScreen> createState() =>
      _EditInformationScreenState();
}

class _EditInformationScreenState extends ConsumerState<EditInformationScreen> {
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _nationality = TextEditingController();




  ProfileModel? _original;

  String? _phone;
  String? _gender;
  DateTime? _dob;

  String? _currentAvatarUrl;
  File? _pickedAvatar;
  bool _removeAvatar = false;



  String? _emailError;


  bool _isPicking = false;



  final ScrollController _scrollController = ScrollController();

  static const double _fieldGap = 18;




  static final DateTime _earliestBirthday = DateTime(1900);
  static DateTime get _latestBirthday => DateTime.now();

  @override
  void initState() {
    super.initState();
    final PersonalInformationData? data = ref
        .read(getProfileProvider)
        .valueOrNull;
    if (data != null) _prefill(data);
    _email.addListener(_clearEmailError);
  }

  @override
  void dispose() {
    _email.removeListener(_clearEmailError);
    _fullName.dispose();
    _email.dispose();
    _nationality.dispose();
    _scrollController.dispose();
    super.dispose();
  }







  void _prefill(PersonalInformationData data) {
    final ProfileModel p = data.profile;
    _original = p;
    _fullName.text = p.fullName ?? '';
    _email.text = p.email ?? '';
    _nationality.text = p.nationality ?? '';
    _phone = p.phone;
    _gender = p.gender;
    _dob = p.birthday == null ? null : DateTime.tryParse(p.birthday!);
    _currentAvatarUrl = data.avatarUrl;
  }

  void _clearEmailError() {
    if (_emailError != null) setState(() => _emailError = null);
  }


  ProfileModel get _edited => ProfileModel(
    fullName: _clean(_fullName.text),
    email: _clean(_email.text),
    gender: _gender,
    birthday: _dob == null ? null : _apiDate(_dob!),
    nationality: _clean(_nationality.text),
  );

  bool get _hasUnsavedChanges =>
      _pickedAvatar != null ||
      _removeAvatar ||
      _edited.changesFrom(_original).isNotEmpty;





  int get _genderTabIndex => switch (_gender?.trim().toLowerCase()) {
    'male' => 0,
    'female' => 1,
    _ => -1,
  };


  String? _dobText(BuildContext context) =>
      _dob == null ? null : formatLocalizedDateOnly(context, _apiDate(_dob!));

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final DateTime latest = _latestBirthday;
    final DateTime fallback = DateTime(
      latest.year - 20,
      latest.month,
      latest.day,
    );


    final DateTime initial = switch (_dob) {
      null => fallback,
      final DateTime d when d.isBefore(_earliestBirthday) => _earliestBirthday,
      final DateTime d when d.isAfter(latest) => latest,
      final DateTime d => d,
    };

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _earliestBirthday,
      lastDate: latest,
      builder: (BuildContext pickerContext, Widget? child) {
        final AppColorScheme colors = pickerContext.colors;
        final ThemeData base = Theme.of(pickerContext);
        return Theme(
          data: base.copyWith(
            colorScheme: base.colorScheme.copyWith(
              primary: colors.primary500Main,
              onPrimary: colors.white,
              surface: colors.white,
              onSurface: colors.black,
            ),
            dividerColor: colors.primary500Main,
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
    if (picked != null && mounted) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _onAvatarTap() async {
    FocusScope.of(context).unfocus();
    final bool hasAvatar =
        _pickedAvatar != null ||
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
    } else if (action == _AvatarAction.remove && mounted) {
      setState(() {
        _pickedAvatar = null;
        _removeAvatar = true;
      });
    }
  }





  Future<void> _pickAvatar() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,


        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked != null && mounted) {
        setState(() {
          _pickedAvatar = File(picked.path);
          _removeAvatar = false;
        });
      }
    } catch (_) {
      if (mounted) {
        AppToast.showError(context, LangKeys.imagePickingErrorKey);
      }
    } finally {
      _isPicking = false;
    }
  }

  String? _clean(String text) {
    final String trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }





  String? _ltrPhone(String? phone) {
    if (phone == null || phone.isEmpty) return null;

    return '\u{2066}${AppValidator.saudiPhoneDisplay(phone)}\u{2069}';
  }



  String _apiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';



  bool _validate() {
    final String email = _email.text.trim();
    final bool ok = email.isEmpty || AppValidator.isValidEmail(email);
    setState(() => _emailError = ok ? null : LangKeys.invalidEmailKey.tr());
    return ok;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    final bool ok = await ref
        .read(updateProfileProvider.notifier)
        .save(
          _edited,
          original: _original,
          avatar: _pickedAvatar,
          removeAvatar: _removeAvatar,
        );
    if (!mounted) return;

    if (ok) {
      AppToast.showSuccess(context, LangKeys.profileUpdatedKey);
      context.pop();
    } else {
      final Object? error = ref.read(updateProfileProvider).error;
      AppToast.showError(
        context,
        error?.toString() ?? LangKeys.serverConnectionFailedKey,
      );
    }
  }



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

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PersonalInformationData> profile = ref.watch(
      getProfileProvider,
    );




    ref.listen<AsyncValue<PersonalInformationData>>(getProfileProvider, (
      AsyncValue<PersonalInformationData>? previous,
      AsyncValue<PersonalInformationData> next,
    ) {
      if (_original != null) return;
      final PersonalInformationData? data = next.valueOrNull;
      if (data != null) setState(() => _prefill(data));
    });

    final bool saving = ref.watch(updateProfileProvider).isLoading;

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
          appBarTitle: LangKeys.editInformationKey.tr(),
          scrollController: _scrollController,
          body: _original == null
              ? _notReady(profile)
              : _form(context, saving: saving),
        ),
      ),
    );
  }




  Widget _notReady(AsyncValue<PersonalInformationData> profile) {
    return profile.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, _) => ServerConnectionErrorWidget(
        message: error.toString(),
        onRetry: () => ref.read(getProfileProvider.notifier).getProfile(),
      ),


      data: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _form(BuildContext context, {required bool saving}) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,



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
                        maxLength: 80,
                        errorText: _emailError,
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
                        initialIndex: _genderTabIndex,
                        activeColor: context.colors.primary500Main,
                        activeFontColor: context.colors.white,
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
                        maxLength: 40,
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
    );
  }
}


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


enum _AvatarAction { pick, remove }
