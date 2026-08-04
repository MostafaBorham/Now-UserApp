import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/offers_cannot_wait/offers_cannot_wait_view.dart';

import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';

import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';

class OffersCannotWaitScreen extends StatelessWidget {
  const OffersCannotWaitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Scaffold(
      body: AppWavedView(
        body: Column(
          spacing: 11,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr(LangKeys.categoriesKey),
              style: AppTextStyles.style14SemiBold.copyWith(
                color: colors.black,
              ),
            ),
            Expanded(
              child: CustomButtonTabBar(
                tabs: [LangKeys.allKey.tr(), 'Devices', 'sddssdsd', 'aaaaaaa'],
                views: [
                  OffersCannotWaitView(),
                  OffersCannotWaitView(),
                  OffersCannotWaitView(),
                  OffersCannotWaitView(),
                ],
                selectedTabColor: colors.secondary600.withValues(alpha: 0.8),
                unSelectedTabColor: colors.neutral400.withValues(
                  alpha: 0.2,
                ),
                selectedLabelColor: colors.black,
                unSelectedLabelColor: colors.black,
              ),
            ),
          ],
        ),
        appBarTitle: context.tr(LangKeys.offersYouCannotWaitForKey),
      ),
    );
  }
}
