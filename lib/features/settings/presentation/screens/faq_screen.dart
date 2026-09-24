import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/app_info_model.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/faq_model.dart';
import 'package:nowdelivery_user_app/features/settings/viewmodel/get_app_info_vm.dart';
import '../widgets/faq_tile.dart';
import '../widgets/faq_tile_shimmer.dart';


class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<int> _expanded = {0};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggle(int index) {
    setState(() {
      if (!_expanded.remove(index)) _expanded.add(index);
    });
  }

  Future<void> _loadAppInfo() =>
      ref.read(getAppInfoProvider.notifier).getAppInfo();

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AppInfoModel> appInfoState = ref.watch(getAppInfoProvider);

    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.faq.tr(),
        scrollController: _scrollController,
        body: appInfoState.when(
          loading: () => AppShimmer(
            child: ListView.separated(
              // Matches the loaded list's top spacing so the loading and data
              // states line up under the wave (AppWavedView drops the body's
              // top padding once a scroll controller is wired in).
              padding: const EdgeInsets.only(top: 57),
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
                  ? NoResultsWidget(
                      isScrollable: true,
                      emptyMessage: LangKeys.noFaqsYetKey.tr(),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      // Owns the top spacing AppWavedView drops when a scroll
                      // controller is wired in, so it scrolls up with the
                      // content and flattens the wave.
                      padding: const EdgeInsets.only(top: 57),
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
