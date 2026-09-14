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

/// Editable "Edit Information" screen, reached from the Edit button on the
/// Personal Information screen.
///
/// Prefilled from the already-loaded [getProfileProvider] data, which is also
/// kept as the baseline: saving sends only the fields that actually differ from
/// it (see [ProfileModel.changesFrom]), so a field the user never touched is
/// never written back. Until that baseline exists the form is not shown at all
/// — an empty form would otherwise save blanks over a good server record.
///
/// Saving goes through [updateProfileProvider] (PUT + JSON, or POST + multipart
/// when the avatar changed); on success it pops and the read screen refreshes
/// itself. Phone is read-only (it is the OTP identity).
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

  /// The profile as it was loaded. Every save is a diff against this, and its
  /// absence is what the "not ready" state keys off — so it is set in exactly
  /// one place, [_prefill].
  ProfileModel? _original;

  String? _phone; // read-only display
  String? _gender; // raw server value; only a tap replaces it
  DateTime? _dob;

  String? _currentAvatarUrl; // existing remote avatar, shown until changed
  File? _pickedAvatar; // newly picked file to upload
  bool _removeAvatar = false; // user chose to clear the picture

  /// Shown under the email pill after a failed validation, cleared as soon as
  /// the user edits the field again.
  String? _emailError;

  /// Guards against a second picker opening while the first is still up.
  bool _isPicking = false;

  // Drives the AppWavedView wave: it flattens while scrolled and springs back
  // to the curved edge once the list settles at the top.
  final ScrollController _scrollController = ScrollController();

  static const double _fieldGap = 18;

  /// Oldest and youngest birthday the picker will accept. The upper bound is
  /// also what keeps a stored future date from being handed to `showDatePicker`
  /// as an out-of-range `initialDate`.
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

  /// Seeds the form from [data] and records the baseline the save diffs against.
  ///
  /// [_gender] takes the server's value verbatim rather than mapping it onto one
  /// of the two segments. A value the toggle cannot show (anything other than
  /// male/female) then stays as it is and drops out of the diff, instead of
  /// being silently rewritten by a user who only came to fix their name.
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

  /// The form's current values as a model, for diffing and for saving.
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

  /// Which segment the gender toggle should start on. `-1` selects none, which
  /// is the honest rendering when the stored value is missing or is something
  /// the two segments cannot express — better than highlighting "Male" for
  /// someone who never chose it.
  int get _genderTabIndex => switch (_gender?.trim().toLowerCase()) {
    'male' => 0,
    'female' => 1,
    _ => -1,
  };

  /// Localized birthday label (e.g. "September 7, 2026" / Arabic equivalent).
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
    // A stored birthday can sit outside the pickable range (bad data, a future
    // date). `showDatePicker` asserts on that, so clamp before handing it over.
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

  /// Opens the gallery. Mirrors `ComplaintPhotosPicker`: a re-entrancy guard, a
  /// `catch` for the `PlatformException` a denied photo-library permission
  /// throws, and a `mounted` check — the picker is a separate activity the OS
  /// can destroy this screen behind.
  Future<void> _pickAvatar() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        // An avatar is rendered at ~112pt. Capping here is what keeps a 12MP
        // camera photo from being uploaded, and decoded, at full size.
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

  /// Wraps the phone number in a Unicode LTR isolate (LRI … PDI) so its digits
  /// and the leading country-code "+" always read left-to-right, while the
  /// field itself keeps aligning to the start side (hugging the leading icon)
  /// under both Arabic (RTL) and English (LTR).
  String? _ltrPhone(String? phone) {
    if (phone == null || phone.isEmpty) return null;
    // U+2066 LEFT-TO-RIGHT ISOLATE … U+2069 POP DIRECTIONAL ISOLATE.
    return '\u{2066}${AppValidator.saudiPhoneDisplay(phone)}\u{2069}';
  }

  /// DateTime → 'YYYY-MM-DD' for the API. Built by hand rather than through
  /// `DateFormat` so the digits stay ASCII regardless of the app locale.
  String _apiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Returns false and marks the field when the email is present but malformed.
  /// An empty email is valid — it simply clears the value.
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

  /// Confirms before throwing away edits. The shared dialog reports through a
  /// callback rather than a pop result, so the answer comes back in a local.
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

    // The screen can be reached before the profile has loaded (a failed session
    // fetch is not retried automatically, and the route is addressable on its
    // own). Re-prefill as soon as data arrives so a retry lands in the form.
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
      // Always false, never `!_hasUnsavedChanges`: `canPop` is read at build
      // time, and typing in a field does not rebuild, so a computed value would
      // answer with whatever was true when the form was last painted. Deciding
      // inside the callback asks the question at the moment back is pressed.
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

  /// Shown until there is a profile to edit. Saving a form we could not prefill
  /// would write blanks over the server record, so the form is withheld
  /// entirely rather than shown empty.
  Widget _notReady(AsyncValue<PersonalInformationData> profile) {
    return profile.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, _) => ServerConnectionErrorWidget(
        message: error.toString(),
        onRetry: () => ref.read(getProfileProvider.notifier).getProfile(),
      ),
      // Data has arrived but the listener has not folded it in yet; the next
      // frame swaps this for the form.
      data: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _form(BuildContext context, {required bool saving}) {
    return Column(
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
