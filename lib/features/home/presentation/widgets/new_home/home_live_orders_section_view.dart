import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/live_order_track_card.dart';

class HomeLiveOrdersSectionView extends StatelessWidget {
  const HomeLiveOrdersSectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<(int, String, List<(String, LiveOrderStepState)>)> orders = [
      (
        5,
        'https://logo.clearbit.com/kfc.com',
        [
          (LangKeys.orderAcceptedKey.tr(), LiveOrderStepState.done),
          (LangKeys.preparingKey.tr(), LiveOrderStepState.done),
          (LangKeys.onTheWayKey.tr(), LiveOrderStepState.going),
          (LangKeys.deliveredKey.tr(), LiveOrderStepState.notTrack),
        ],
      ),
      (
        12,
        'https://logo.clearbit.com/mcdonalds.com',
        [
          (LangKeys.orderAcceptedKey.tr(), LiveOrderStepState.done),
          (LangKeys.preparingKey.tr(), LiveOrderStepState.going),
          (LangKeys.onTheWayKey.tr(), LiveOrderStepState.notTrack),
          (LangKeys.deliveredKey.tr(), LiveOrderStepState.notTrack),
        ],
      ),
      (
        2,
        'https://logo.clearbit.com/pizzahut.com',
        [
          (LangKeys.orderAcceptedKey.tr(), LiveOrderStepState.done),
          (LangKeys.preparingKey.tr(), LiveOrderStepState.done),
          (LangKeys.onTheWayKey.tr(), LiveOrderStepState.done),
          (LangKeys.deliveredKey.tr(), LiveOrderStepState.going),
        ],
      ),
    ];

    return LayoutBuilder(
      builder: (context, con) {
        return SizedBox(
          height: con.maxWidth * 0.3,
          child: ListView.separated(
            padding: const EdgeInsetsDirectional.only(start: 10, end: 10),
            scrollDirection: Axis.horizontal,
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final (int, String, List<(String, LiveOrderStepState)>) order =
                  orders[index];
              return SizedBox(
                width: con.maxWidth * 0.85,
                child: LiveOrderTrackCard(
                  remainingMinutes: order.$1,
                  logoUrl: order.$2,
                  steps: order.$3,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
