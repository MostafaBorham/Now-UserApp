import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/app_info_model.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/privacy_model.dart';
import 'package:nowdelivery_user_app/features/settings/viewmodel/get_app_info_vm.dart';
import '../widgets/privacy_section.dart';
import '../widgets/privacy_section_shimmer.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppInfoModel> appInfoState = ref.watch(getAppInfoProvider);

    Future<void> loadAppInfo() =>
        ref.read(getAppInfoProvider.notifier).getAppInfo();

    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.privacy.tr(),
        body: appInfoState.when(
          loading: () => const AppShimmer(
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 24,
                children: [
                  PrivacySectionShimmer(),
                  PrivacySectionShimmer(),
                  PrivacySectionShimmer(),
                ],
              ),
            ),
          ),
          error: (Object error, _) => ServerConnectionErrorWidget(
            message: error.toString(),
            onRetry: loadAppInfo,
          ),
          data: (AppInfoModel appInfo) {
            final PrivacyModel? content = appInfo.content;
            final String terms = context.getLocalizedApiText(content?.terms);
            final String privacy = context.getLocalizedApiText(
              content?.privacy,
            );
            final String about = context.getLocalizedApiText(content?.about);

            final bool isEmpty =
                terms.isEmpty && privacy.isEmpty && about.isEmpty;
            final TextStyle titleStyle = AppTextStyles.style18Medium;

            final DateTime? updatedAt = DateTime.tryParse(
              content?.privacyUpdatedAt ?? '',
            );
            final String effectiveDate = updatedAt == null
                ? LangKeys.privacyEffectiveDate.tr()
                : '${LangKeys.privacyEffectiveDate.tr()}: '
                      '${DateFormat.yMMMMd(context.locale.toString()).format(updatedAt)}';

            return isEmpty
                ? NoResultsWidget(
                    isScrollable: true,
                    emptyMessage: LangKeys.noItemsYetKey.tr(),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 24,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              effectiveDate,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.style18Medium.copyWith(
                                color: context.colors.tertiaryContainer,
                                height: 1.55,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              LangKeys.privacyIntro.tr(),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.style14Regular.copyWith(
                                color: context.colors.outline,
                                height: 1.43,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                        if (terms.isNotEmpty)
                          PrivacySection(
                            title: LangKeys.appTerms.tr(),
                            body: terms,
                            titleStyle: titleStyle,
                          ),
                        if (privacy.isNotEmpty)
                          PrivacySection(
                            title: LangKeys.appPrivacy.tr(),
                            body: privacy,
                            titleStyle: titleStyle,
                          ),
                        if (about.isNotEmpty)
                          PrivacySection(
                            title: LangKeys.appAbout.tr(),
                            body: about,
                            titleStyle: titleStyle,
                          ),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }
}
