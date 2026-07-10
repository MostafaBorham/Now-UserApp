import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/enums/online_card_types.dart';
import 'package:nowdelivery_user_app/core/params/online_card_params.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';

import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/online_card_radio_selector.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';

class MyCardsView extends StatefulWidget {
  const MyCardsView({super.key});

  @override
  State<MyCardsView> createState() => _MyCardsViewState();
}

class _MyCardsViewState extends State<MyCardsView> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 10,
            children: [
              AutoSizeText(
                LangKeys.myCardsKey.tr(),
                style: AppTextStyles.style18Medium.copyWith(
                  color: colors.onSecondary,
                ),
              ),
              IconButton(
                padding: EdgeInsetsGeometry.zero,
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  context.pop();
                },
                icon: Icon(Icons.clear, size: 20, color: colors.onSecondary),
              ),
            ],
          ),
          Expanded(
            child: OnlineCardRadioSelector(
              cards: [
                OnlineCardParams(
                  cardHolder: 'Mostafa Borham',
                  cardNumber: '4701 1221 1212 12212',
                  cardType: OnlineCardTypes.visa,
                ),
                OnlineCardParams(
                  cardHolder: 'Basem ahmed',
                  cardNumber: '5201 1221 1212 12212',
                  cardType: OnlineCardTypes.master,
                ),
              ],
              onAmountChanged: (card) {},
            ),
          ),
          5.hSpace,
          PrimaryAppButton(title: LangKeys.addNewCardKey.tr()),
        ],
      ),
    );
  }
}
