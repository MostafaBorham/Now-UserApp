import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/add_card_view.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/add_balance_view.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/my_cards_view.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/wallet_action_button.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/wallet_card_widget.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/wallet_history_item.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final Size screenSize = MediaQuery.sizeOf(context);
    return AppWavedView(
      appBarTitle: LangKeys.walletKey.tr(),
      canPop: context.canPop(),
      body: Column(
        spacing: screenSize.height * 0.03,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(aspectRatio: 2, child: WalletCardWidget()),
          Row(
            spacing: 5,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 3,
                  child: WalletActionButton(
                    actionName: LangKeys.addBalanceKey.tr(),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: colors.onPrimary,
                        builder: (context) => ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * 0.6,
                          ),
                          child: AddBalanceView(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 3,
                  child: WalletActionButton(
                    actionName: LangKeys.myCardsKey.tr(),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: colors.onPrimary,
                        builder: (context) => ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * 0.6,
                          ),
                          child: MyCardsView(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 3,
                  child: WalletActionButton(
                    actionName: LangKeys.addCardKey.tr(),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: colors.onPrimary,
                        builder: (context) => ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * 0.6,
                          ),
                          child: AddCardView(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              spacing: screenSize.height * 0.015,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LangKeys.walletRecordKey.tr(),
                  style: AppTextStyles.style18SemiBold.copyWith(
                    color: colors.onSecondary,
                    fontSize: screenSize.width * 0.04,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) => AspectRatio(
                      aspectRatio: 5.5,
                      child: WalletHistoryItem(),
                    ),
                    separatorBuilder: (context, index) => 12.hSpace,
                    itemCount: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
