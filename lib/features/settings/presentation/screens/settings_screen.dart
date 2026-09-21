import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/enums/session_types.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';

import '../widgets/settings_guest_view.dart';
import '../widgets/settings_user_view.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isUser =
        ref.watch(authSessionProvider.select((s) => s.sessionType)) ==
        SessionType.user;

    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.profileKey.tr(),
        canPop: false,
        scrollController: _scrollController,
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
          child: isUser ? const SettingsUserView() : const SettingsGuestView(),
        ),
      ),
    );
  }
}
