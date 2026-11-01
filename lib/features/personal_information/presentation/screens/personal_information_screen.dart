import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/formatters/date_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/app_validator.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';

import '../widgets/info_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/profile_avatar.dart';

/// Read-only "Personal Information" screen, shown when the user taps the
/// Personal Information tile on the profile screen.
///
/// Watches [getProfileProvider] (`GET /api/v1/user/profile`) and renders the
/// [AsyncValue]: a spinner while loading, the shared error widget with retry on
/// failure, and the read-only [InfoField]s on success. The avatar is a static
/// placeholder for now (avatar wiring is deferred). The "Edit" button opens
/// [EditInformationScreen].
class PersonalInformationScreen extends ConsumerStatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  ConsumerState<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends ConsumerState<PersonalInformationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(getProfileProvider);

    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.personalInformationKey.tr(),
        scrollController: _scrollController,
        body: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, _) => ServerConnectionErrorWidget(
            message: error.toString(),
            onRetry: () => ref.read(getProfileProvider.notifier).getProfile(),
          ),
          data: (data) => _ProfileBody(
            profile: data.profile,
            avatarUrl: data.avatarUrl,
            scrollController: _scrollController,
          ),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.profile,
    this.avatarUrl,
    this.scrollController,
  });

  final ProfileModel profile;
  final String? avatarUrl;
  final ScrollController? scrollController;

  /// Placeholder for a value the user has not set and that has no hint of its
  /// own to offer (a name or phone they cannot fill in from here).
  static const String _emptyHint = '—';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      // Owns the top spacing AppWavedView drops when a scroll controller is
      // wired in, so it scrolls up with the content.
      padding: const EdgeInsets.only(top: 57, bottom: 32),
      child: Column(
        children: [
          const SizedBox(height: 24),
          ProfileAvatar(size: 140, imageUrl: avatarUrl, fullScreenOnTap: true),
          const SizedBox(height: 28),
          Material(
            color: context.colors.onTertiaryContainer,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoField(
                    label: LangKeys.fullNameKey.tr(),
                    value: profile.fullName,
                    hint: _emptyHint,
                  ),
                  InfoField(
                    label: LangKeys.phoneKey.tr(),
                    value: AppValidator.saudiPhoneDisplay(profile.phone),
                    hint: _emptyHint,
                    // The only always-Latin value on this screen.
                    forceLtrValue: true,
                  ),
                  InfoField(
                    label: LangKeys.emailKey.tr(),
                    value: profile.email,
                    hint: LangKeys.enterEmailAddressKey.tr(),
                  ),
                  InfoField(
                    label: LangKeys.genderKey.tr(),
                    value: _localizedGender(profile.gender),
                    hint: _emptyHint,
                  ),
                  InfoField(
                    label: LangKeys.dateOfBirthKey.tr(),
                    // Localized, so the same birthday reads the same here as it
                    // does in the editor.
                    value: formatLocalizedDateOnly(context, profile.birthday),
                    hint: LangKeys.selectDateOfBirthKey.tr(),
                    showDivider: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: LangKeys.editKey.tr(),
            onPressed: () => context.pushNamed(AppRoutes.editInformationScreen),
          ),
        ],
      ),
    );
  }

  /// Maps the raw server gender ('male' | 'female' | 'other') to its localized
  /// label. Returns null (so the hint shows) when empty, and falls back to the
  /// raw value for any unexpected server string.
  String? _localizedGender(String? value) {
    switch (value?.toLowerCase()) {
      case 'male':
        return LangKeys.maleKey.tr();
      case 'female':
        return LangKeys.femaleKey.tr();
      case 'other':
        return LangKeys.otherKey.tr();
      case null:
      case '':
        return null;
      default:
        return value;
    }
  }
}
