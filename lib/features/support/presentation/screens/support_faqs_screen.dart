import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/faq_model.dart';
import 'package:nowdelivery_user_app/features/settings/presentation/widgets/faq_tile.dart';
import 'package:nowdelivery_user_app/features/settings/presentation/widgets/faq_tile_shimmer.dart';
import 'package:nowdelivery_user_app/features/support/viewmodel/get_support_faqs_vm.dart';

class SupportFaqsScreen extends ConsumerStatefulWidget {
  const SupportFaqsScreen({super.key});

  @override
  ConsumerState<SupportFaqsScreen> createState() => _SupportFaqsScreenState();
}

class _SupportFaqsScreenState extends ConsumerState<SupportFaqsScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<int> _expanded = {};

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

  Future<void> _loadFaqs() =>
      ref.read(getSupportFaqsProvider.notifier).getSupportFaqs();

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<FaqModel>> faqsState =
        ref.watch(getSupportFaqsProvider);

    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.supportLabel.tr(),
        scrollController: _scrollController,
        body: faqsState.when(
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
            onRetry: _loadFaqs,
          ),
          data: (List<FaqModel> faqs) {
            return AppRefreshIndicator(
              onRefresh: _loadFaqs,
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
                      // One extra trailing item: the "Other" tile that routes
                      // to the support screen.
                      itemCount: faqs.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        // Trailing "Other" entry: styled like a collapsed
                        // FaqTile but routes to the support screen instead of
                        // expanding, and carries no chevron.
                        if (index == faqs.length) {
                          return Material(
                            color: context.colors.onTertiaryContainer,
                            borderRadius: BorderRadius.circular(16),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () =>
                                  context.pushNamed(AppRoutes.supportScreen),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    LangKeys.otherKey.tr(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.3,
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.tertiaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

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
