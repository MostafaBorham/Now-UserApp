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



  static const String _emptyHint = '—';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,


      padding: const EdgeInsets.only(top: 57, bottom: 32),
      child: Column(
        children: [
          const SizedBox(height: 24),
          ProfileAvatar(size: 112, imageUrl: avatarUrl),
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


                    value: formatLocalizedDateOnly(context, profile.birthday),
                    hint: LangKeys.selectDateOfBirthKey.tr(),
                  ),
                  InfoField(
                    label: LangKeys.nationalityKey.tr(),
                    value: profile.nationality,
                    hint: LangKeys.enterNationalityKey.tr(),
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
