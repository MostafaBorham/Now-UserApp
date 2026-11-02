import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/faq_model.dart';
import 'package:nowdelivery_user_app/features/settings/presentation/widgets/faq_card_shell.dart';
import 'package:nowdelivery_user_app/features/settings/presentation/widgets/faq_tile.dart';
import 'package:nowdelivery_user_app/features/support/data/repo/support_repo.dart';

class SupportFaqsScreen extends StatefulWidget {
  const SupportFaqsScreen({super.key, required this.faqs});

  final List<FaqModel> faqs;

  /// The support icon's tap: loads the FAQs while the icon spins, then lists
  /// them, or opens the support chat directly when there are none ("Other"
  /// would be the only choice).
  static Future<void> open(BuildContext context) async {
    final result = await SupportRepo().getSupportFaqs();
    if (!context.mounted) return;
    // Not awaited: a push completes only when its screen pops.
    result.fold(
      (Failure failure) => AppToast.showError(context, failure.message.tr()),
      (List<FaqModel> faqs) => faqs.isEmpty
          ? context.pushNamed(AppRoutes.supportScreen)
          : context.pushNamed(AppRoutes.supportFaqsScreen, extra: faqs),
    );
  }

  @override
  State<SupportFaqsScreen> createState() => _SupportFaqsScreenState();
}

class _SupportFaqsScreenState extends State<SupportFaqsScreen> {
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

  @override
  Widget build(BuildContext context) {
    final List<FaqModel> faqs = widget.faqs;

    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.supportLabel.tr(),
        scrollController: _scrollController,
        body: ListView.separated(
          controller: _scrollController,
          // Owns the top spacing AppWavedView drops when a scroll controller
          // is wired in, so it scrolls up with the content.
          padding: const EdgeInsets.only(top: 57),
          // One extra trailing item: the "Other" tile that routes to the
          // support screen.
          itemCount: faqs.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            // Trailing "Other" entry: styled like a collapsed FaqTile but
            // routes to the support screen instead of expanding, and carries
            // no chevron.
            if (index == faqs.length) {
              return FaqCardShell(
                onTap: () => context.pushNamed(AppRoutes.supportScreen),
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
      ),
    );
  }
}
