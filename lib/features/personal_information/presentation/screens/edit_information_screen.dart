import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nowdelivery_user_app/core/formatters/date_formatter.dart';
import 'package:nowdelivery_user_app/core/formatters/name_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/components/image_source_sheet.dart';
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

  ProfileModel? _original;

  String? _phone;
  String? _gender;
  DateTime? _dob;

  String? _currentAvatarUrl;
  File? _pickedAvatar;
  bool _removeAvatar = false;

  String? _nameError;
  String? _emailError;

  bool _isPicking = false;

  final ScrollController _scrollController = ScrollController();

  static const double _fieldGap = 18;

  /// Ages 12 to 100, a product rule the app alone enforces: the API only
  /// checks `before:today` (`User/UpdateProfileRequest`), which the minimum
  /// already covers.
  static DateTime get _earliestBirthday => _yearsAgo(100);
  static DateTime get _latestBirthday => _yearsAgo(12);

  static DateTime _yearsAgo(int years) {
    final DateTime now = DateTime.now();
    return DateTime(now.year - years, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    final PersonalInformationData? data = ref
        .read(getProfileProvider)
        .valueOrNull;
    if (data != null) _prefill(data);
    _fullName.addListener(_clearNameError);
    _email.addListener(_clearEmailError);
    // Save is enabled only once the form differs from the saved profile, so
    // typing has to rebuild it.
    _fullName.addListener(_onFieldChanged);
    _email.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _fullName
      ..removeListener(_clearNameError)
      ..removeListener(_onFieldChanged)
      ..dispose();
    _email
      ..removeListener(_clearEmailError)
      ..removeListener(_onFieldChanged);
    _email.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _prefill(PersonalInformationData data) {
    final ProfileModel p = data.profile;
    _original = p;
    _fullName.text = p.fullName ?? '';
    _email.text = p.email ?? '';
    _phone = p.phone;
    _gender = p.gender;
    _dob = p.birthday == null ? null : DateTime.tryParse(p.birthday!);
    _currentAvatarUrl = data.avatarUrl;
  }

  void _clearNameError() {
    if (_nameError != null) setState(() => _nameError = null);
  }

  void _clearEmailError() {
    if (_emailError != null) setState(() => _emailError = null);
  }

  /// A name the user left as it was keeps its stored spelling (outer spacing
  /// included), so opening and saving the form never sends a name change
  /// nobody made.
  String? get _editedFullName {
    final String? cleaned = _clean(_fullName.text);
    return cleaned == _original?.fullName?.trim()
        ? _original?.fullName
        : cleaned;
  }

  ProfileModel get _edited => ProfileModel(
    fullName: _editedFullName,
    email: _clean(_email.text),
    gender: _gender,
    birthday: _dob == null ? null : _apiDate(_dob!),
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
    final DateTime earliest = _earliestBirthday;
    final DateTime latest = _latestBirthday;
    final DateTime fallback = DateTime(
      latest.year - 20,
      latest.month,
      latest.day,
    );

    final DateTime initial = switch (_dob) {
      null => fallback,
      final DateTime d when d.isBefore(earliest) => earliest,
      final DateTime d when d.isAfter(latest) => latest,
      final DateTime d => d,
    };

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: earliest,
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
              // The year grid draws unselected years in this, which the app
              // theme sets to a pale green that barely shows on white.
              onSurfaceVariant: colors.tertiaryContainer,
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

    final ImageSource? source = await showImageSourceSheet(
      context,
      onRemove: hasAvatar
          ? () => setState(() {
              _pickedAvatar = null;
              _removeAvatar = true;
            })
          : null,
    );
    if (source != null) await _pickAvatar(source);
  }

  Future<void> _pickAvatar(ImageSource source) async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: source,
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
    // Same rule as the completion screen. An emptied name used to be saved as
    // `full_name: null`, which the backend accepts — and a user with no name
    // is sent straight back to the completion screen.
    final String? nameError = _fullName.text.trim().isEmpty
        ? LangKeys.nameRequiredKey.tr()
        : null;
    final String? emailError = email.isEmpty || AppValidator.isValidEmail(email)
        ? null
        : LangKeys.invalidEmailKey.tr();
    setState(() {
      _nameError = nameError;
      _emailError = emailError;
    });
    return nameError == null && emailError == null;
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
        error?.toString() ?? LangKeys.somethingWentWrongKey,
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
                      // Same cap as the completion screen.
                      EditField(
                        label: LangKeys.fullNameKey.tr(),
                        controller: _fullName,
                        leadingAsset: Assets.media.images.svg.pen.path,
                        maxLength: 80,
                        inputFormatters: <TextInputFormatter>[
                          nameInputFormatter,
                        ],
                        errorText: _nameError,
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
                        // Latin text: laid out RTL, Arabic reorders it around
                        // `@` and `.`.
                        textDirection: TextDirection.ltr,
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
                        onTaptab: (currentTab) => setState(
                          () => _gender = currentTab == 1 ? 'female' : 'male',
                        ),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _SaveBar(
          isLoading: saving,
          isDisabled: !_hasUnsavedChanges,
          onSave: _save,
        ),
      ],
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.onSave,
    required this.isLoading,
    required this.isDisabled,
  });

  final VoidCallback onSave;
  final bool isDisabled;
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
          isDisabled: isDisabled,
          onPressed: onSave,
        ),
      ),
    );
  }
}
