import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/app_info_model.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/faq_model.dart';
import 'package:nowdelivery_user_app/features/settings/viewmodel/get_app_info_vm.dart';
import '../widgets/faq_tile.dart';
import '../widgets/faq_tile_shimmer.dart';

/// FAQ screen: a list of expandable question cards fed by [getAppInfoProvider].
///
/// Watches the application-information [AsyncValue] and renders the FAQ list
/// from [FaqModel]; localized `question` / `answer` maps are resolved for the
/// current locale via [LocaleExt.getLocalizedApiText]. Any number of tiles can
/// be open and the first one is open by default.
class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> {
  final Set<int> _expanded = {0};

  void _toggle(int index) {
    setState(() {
      if (!_expanded.remove(index)) _expanded.add(index);
    });
  }

  /// Single entry point for (re)loading the application information — shared by
  /// the error-state retry and the pull-to-refresh gesture.
  Future<void> _loadAppInfo() =>
      ref.read(getAppInfoProvider.notifier).getAppInfo();

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AppInfoModel> appInfoState = ref.watch(getAppInfoProvider);

    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.faq.tr(),
        body: appInfoState.when(
          loading: () => AppShimmer(
            child: ListView.separated(
              itemCount: 6,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (_, _) => const FaqTileShimmer(),
            ),
          ),
          error: (Object error, _) => ServerConnectionErrorWidget(
            message: error.toString(),
            onRetry: _loadAppInfo,
          ),
          data: (AppInfoModel appInfo) {
            final List<FaqModel> faqs = appInfo.faqs;

            return AppRefreshIndicator(
              onRefresh: _loadAppInfo,
              child: faqs.isEmpty
                  ? NoItemsWidget(
                      isScrollable: true,
                      emptyMessage: LangKeys.noFaqsYetKey.tr(),
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: faqs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final FaqModel faq = faqs[index];
                        return FaqTile(
                          question: context.getLocalizedApiText(faq.question),
                          answer: context.getLocalizedApiText(faq.answer),
                          expanded: _expanded.contains(index),
                          onTap: () => _toggle(index),
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
