import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/components/image_source_sheet.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/utils/app_validator.dart';
import 'package:nowdelivery_user_app/core/utils/auth_guard.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';
import 'package:nowdelivery_user_app/features/personal_information/presentation/widgets/profile_avatar.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/update_profile_vm.dart';

import '../widgets/complete_profile/complete_profile_form.dart';

/// The step between OTP verification and the app: the user names themselves
/// (and optionally adds a photo and an email) before returning to the screen
/// the login started from.
///
/// **Mandatory.** There is no skip and no back button: the user is sent here
/// whenever the server reports `profile_completed: false`, and the only way out
/// is a successful save. Backing out would drop them into the app in exactly
/// the state the flag exists to prevent.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _email = TextEditingController();

  File? _avatar;
  String? _nameError;
  String? _emailError;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_clearNameError);
    _email.addListener(_clearEmailError);
  }

  @override
  void dispose() {
    _fullNameController
      ..removeListener(_clearNameError)
      ..dispose();
    _email
      ..removeListener(_clearEmailError)
      ..dispose();
    super.dispose();
  }

  void _clearNameError() {
    if (_nameError != null) setState(() => _nameError = null);
  }

  void _clearEmailError() {
    if (_emailError != null) setState(() => _emailError = null);
  }

  String get _fullName => _fullNameController.text.trim();

  Future<void> _pickAvatar() async {
    if (_isPicking) return;
    FocusScope.of(context).unfocus();
    final ImageSource? source = await showImageSourceSheet(context);
    if (source == null || _isPicking) return;
    _isPicking = true;

    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked != null && mounted) {
        setState(() => _avatar = File(picked.path));
      }
    } catch (_) {
      if (mounted) AppToast.showError(context, LangKeys.imagePickingErrorKey);
    } finally {
      _isPicking = false;
    }
  }

  bool _validate() {
    final String email = _email.text.trim();
    final String? nameError = _fullName.isEmpty
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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    final String email = _email.text.trim();
    final bool saved = await ref
        .read(updateProfileProvider.notifier)
        .save(
          ProfileModel(
            fullName: _fullName,
            email: email.isEmpty ? null : email,
          ),
          // A brand-new profile has nothing to diff against, so everything set
          // here is sent.
          original: null,
          avatar: _avatar,
        );
    if (!mounted) return;

    if (saved) {
      leaveLoginFlow(context);
    } else {
      final Object? error = ref.read(updateProfileProvider).error;
      AppToast.showError(
        context,
        error?.toString() ?? LangKeys.somethingWentWrongKey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSaving = ref.watch(updateProfileProvider).isLoading;

    return PopScope(
      // Mandatory step: the system back gesture must not return to the OTP
      // screen or slip past this into the app.
      canPop: false,
      child: Scaffold(
        body: AppWavedView(
          appBarTitle: LangKeys.personalInformationKey.tr(),
          canPop: false,
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: ProfileAvatar(
                          size: 112,
                          showCameraOverlay: true,
                          imageFile: _avatar,
                          onCameraTap: _pickAvatar,
                        ),
                      ),
                      const SizedBox(height: 32),
                      CompleteProfileForm(
                        fullName: _fullNameController,
                        email: _email,
                        nameError: _nameError,
                        emailError: _emailError,
                      ),
                    ],
                  ),
                ),
              ),
              PrimaryAppButton(
                title: LangKeys.continueKey.tr(),
                isLoading: isSaving,
                onTap: _submit,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
