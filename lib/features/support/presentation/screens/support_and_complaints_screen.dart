import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/arrow_back_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/top_wave_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/app_tab_bar.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';

class SupportAndComplaintsScreen extends StatelessWidget {
  const SupportAndComplaintsScreen({super.key, this.tickets});

  /// When omitted, shows the design's sample tickets until the API is ready.
  final List<ComplaintTicketPreview>? tickets;

  @override
  Widget build(BuildContext context) {
    final allTickets = tickets ?? _sampleTickets(context);
    const statuses = ComplaintTicketStatus.values;
    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.supportAndComplaintsKey.tr(),
        waveGap: 8,
        bodyPadding: EdgeInsets.only(
          top: TopWaveClipper.depthFor(MediaQuery.sizeOf(context).width),
          left: 8,
          right: 8,
        ),
        leading: Tooltip(
          message: MaterialLocalizations.of(context).backButtonTooltip,
          child: CircleAvatar(
            radius: 24,
            backgroundColor: context.colors.white,
            child: ReverseWidget(
              child: ArrowBackButton(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.goNamed(AppRoutes.mainScreen);
                  }
                },
              ),
            ),
          ),
        ),
        body: AppTabBar(
          selectedTabColor: context.colors.primary500Main,
          isScrollable: true,
          tabs: [
            LangKeys.allKey.tr(),
            for (final status in statuses) status.label.tr(),
          ],
          views: [
            _buildTickets(allTickets),
            for (final status in statuses)
              _buildTickets(
                allTickets.where((ticket) => ticket.status == status).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTickets(List<ComplaintTicketPreview> visibleTickets) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView.separated(
        padding: visibleTickets.isEmpty
            ? const EdgeInsets.symmetric(horizontal: 11)
            : const EdgeInsets.fromLTRB(3, 0, 3, 8),
        itemCount: visibleTickets.isEmpty ? 1 : visibleTickets.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) => visibleTickets.isEmpty
            ? SizedBox(
                height: math.min(497, constraints.maxHeight),
                child: const _EmptyTickets(),
              )
            : _TicketCard(ticket: visibleTickets[index]),
      ),
    );
  }
}

class ComplaintTicketPreview {
  const ComplaintTicketPreview({
    required this.number,
    required this.status,
    required this.title,
    required this.reply,
    required this.timeLabel,
  });

  final String number;
  final ComplaintTicketStatus status;
  final String title;
  final String reply;
  final String timeLabel;
}

List<ComplaintTicketPreview> _sampleTickets(BuildContext context) {
  const samples = {
    'TK-10234': ComplaintTicketStatus.processing,
    'TK-10229': ComplaintTicketStatus.pending,
    'TK-10218': ComplaintTicketStatus.underReview,
    'TK-10186': ComplaintTicketStatus.closed,
  };
  return [
    for (final sample in samples.entries)
      ComplaintTicketPreview(
        number: sample.key,
        status: sample.value,
        title: context.tr(
          '${LangKeys.complaintDemoTicketsKey}.${sample.key}.title',
        ),
        reply: context.tr(
          '${LangKeys.complaintDemoTicketsKey}.${sample.key}.reply',
        ),
        timeLabel: context.tr(
          '${LangKeys.complaintDemoTicketsKey}.${sample.key}.time',
        ),
      ),
  ];
}

enum ComplaintTicketStatus {
  pending(LangKeys.pendingKey, Color(0xFFCBA400), Color(0xFFFFD008)),
  processing(LangKeys.complaintProcessingKey, Color(0xFFAF52DE)),
  underReview(LangKeys.complaintUnderReviewKey, Color(0xFF30B0C7)),
  closed(LangKeys.complaintClosedKey, Color(0xFF117456), Color(0xFF1ED29C)),
  rejected(LangKeys.complaintRejectedKey, Color(0xFFB91828));

  const ComplaintTicketStatus(this.label, this.color, [this.tint]);

  final String label;
  final Color color;
  final Color? tint;
}

const _mutedText = Color(0xFF5E5E5E);

class _EmptyTickets extends StatelessWidget {
  const _EmptyTickets();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            SizedBox(
              width: 220,
              height: 180,
              child: Center(
                child: Assets.media.images.svg.noComplaintTicketsPlacholder.svg(
                  excludeFromSemantics: true,
                ),
              ),
            ),
            Text(
              LangKeys.noComplaintTicketsKey.tr(),
              style: AppTextStyles.style24Bold.copyWith(
                height: 45 / 24,
                color: context.colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final ComplaintTicketPreview ticket;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = ticket.status;
    final number = ticket.number;
    final caption = AppTextStyles.style12Regular.copyWith(
      height: 22 / 12,
      color: _mutedText,
    );

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: colors.primaryFixed,
        border: Border.all(color: colors.neutral200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  number.isEmpty || number.startsWith('#')
                      ? number
                      : '#$number',
                  textDirection: TextDirection.ltr,
                  textAlign: Directionality.of(context) == TextDirection.rtl
                      ? TextAlign.right
                      : TextAlign.left,
                  maxLines: 1,
                  style: AppTextStyles.style12SemiBold.copyWith(
                    height: 22 / 12,
                    color: _mutedText,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: (status.tint ?? status.color).withValues(alpha: 0.1),
                  shape: const StadiumBorder(),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  child: Text(
                    status.label.tr(),
                    style: AppTextStyles.style12SemiBold.copyWith(
                      height: 22 / 12,
                      color: status.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            ticket.title,
            maxLines: 2,
            style:
                (status == ComplaintTicketStatus.processing
                        ? AppTextStyles.style14Bold
                        : AppTextStyles.style14Regular)
                    .copyWith(height: 26 / 14, color: colors.neutral1200),
          ),
          Row(
            spacing: 6,
            children: [
              Expanded(child: Text(ticket.reply, maxLines: 1, style: caption)),
              if (ticket.timeLabel.isNotEmpty) ...[
                const Icon(Icons.schedule_rounded, size: 14, color: _mutedText),
                Text(ticket.timeLabel, style: caption),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
