import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart' as html_parser;
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

class PrivacyPolicyScreen extends ConsumerStatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  ConsumerState<PrivacyPolicyScreen> createState() =>
      _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends ConsumerState<PrivacyPolicyScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _parseHtml(String text) =>
      html_parser.parse(text).body?.text.trim() ?? '';

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AppInfoModel> appInfoState = ref.watch(getAppInfoProvider);

    Future<void> loadAppInfo() =>
        ref.read(getAppInfoProvider.notifier).getAppInfo();

    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.privacy.tr(),
        scrollController: _scrollController,
        body: appInfoState.when(
          loading: () => const AppShimmer(
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              // Matches the loaded content's top spacing so the loading and data
              // states line up under the wave (AppWavedView drops the body's top
              // padding once a scroll controller is wired in).
              padding: EdgeInsets.only(top: 57),
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
            final String terms = _parseHtml(
              context.getLocalizedApiText(content?.terms),
            );
            final String privacy = _parseHtml(
              context.getLocalizedApiText(content?.privacy),
            );
            // The same rich-text editor authors all three blocks.
            final String about = _parseHtml(
              context.getLocalizedApiText(content?.about),
            );

            final bool isEmpty =
                terms.isEmpty && privacy.isEmpty && about.isEmpty;
            final TextStyle titleStyle = AppTextStyles.style18Medium;

            final String updatedAt = context.getLocalizedApiDate(
              apiDateTimeStamp: content?.privacyUpdatedAt,
            );

            return isEmpty
                ? NoResultsWidget(
                    isScrollable: true,
                    emptyMessage: LangKeys.contentUnavailableKey.tr(),
                  )
                : SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    // Owns the top spacing AppWavedView drops when a scroll
                    // controller is wired in, so it scrolls up with the content.
                    padding: const EdgeInsets.only(top: 57),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 24,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (updatedAt.isNotEmpty) ...[
                              Text(
                                '${LangKeys.privacyEffectiveDate.tr()}: '
                                '$updatedAt',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.style18Medium.copyWith(
                                  color: context.colors.tertiaryContainer,
                                  height: 1.55,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
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
