import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
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
class PersonalInformationScreen extends ConsumerWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(getProfileProvider);

    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.personalInformationKey.tr(),
        body: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, _) => ServerConnectionErrorWidget(
            message: error.toString(),
            onRetry: () => ref.read(getProfileProvider.notifier).getProfile(),
          ),
          data: (data) => _ProfileBody(profile: data.profile),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const ProfileAvatar(size: 112),
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
                  InfoField(label: 'Full Name', value: profile.fullName, hint: '—'),
                  InfoField(label: 'Phone', value: profile.phone, hint: '—'),
                  InfoField(
                    label: 'Email',
                    value: profile.email,
                    hint: 'Enter email address',
                  ),
                  InfoField(
                    label: 'Gender',
                    value: _titleCase(profile.gender),
                    hint: '—',
                  ),
                  InfoField(
                    label: 'Date of Birth',
                    value: profile.birthday,
                    hint: 'Select date of birth',
                  ),
                  InfoField(
                    label: 'Nationality',
                    value: profile.nationality,
                    hint: 'Enter your nationality',
                    showDivider: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Edit',
            onPressed: () => context.pushNamed(AppRoutes.editInformationScreen),
          ),
        ],
      ),
    );
  }

  /// 'male' → 'Male'. Returns null (so the hint shows) when empty.
  String? _titleCase(String? value) {
    if (value == null || value.isEmpty) return null;
    return value[0].toUpperCase() + value.substring(1);
  }
}
