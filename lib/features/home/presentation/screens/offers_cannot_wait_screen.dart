import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/common/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/offers_cannot_wait/offers_cannot_wait_view.dart';

import 'package:nowdelivery_user_app/common/presentation/widgets/app_waved_scaffold.dart';

import 'package:nowdelivery_user_app/common/presentation/widgets/tab_bars/custom_button_tab_bar.dart';

class OffersCannotWaitScreen extends StatelessWidget {
  const OffersCannotWaitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: AppWavedScaffold(
        body: Column(
          spacing: 11,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr(LangKeys.categoriesKey),
              style: AppTextStyles.style14SemiBold.copyWith(
                color: colors.onSecondary,
              ),
            ),
            Expanded(
              child: CustomButtonTabBar(
                tabs: [LangKeys.allKey.tr(), 'Devices','sddssdsd','aaaaaaa'],
                views: [
                  OffersCannotWaitView(),
                  OffersCannotWaitView(),
                  OffersCannotWaitView(),
                  OffersCannotWaitView(),
                ],
                selectedTabColor: colors.secondary.withValues(alpha: 0.8),
                unSelectedTabColor: colors.inversePrimary.withValues(alpha: 0.2),
                selectedLabelColor: colors.onSecondary,
                unSelectedLabelColor: colors.onSecondary,
              ),
            ),
          ],
        ),
        appBarTitle: context.tr(LangKeys.offersYouCannotWaitForKey),
      ),
    );
  }
}
