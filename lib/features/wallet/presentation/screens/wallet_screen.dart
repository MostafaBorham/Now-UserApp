import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/reverse_widget.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/show_more_items_header.dart';
import 'package:nowdelivery_user_app/view/widgets/wallet/add_card_view.dart';
import 'package:nowdelivery_user_app/view/widgets/wallet/add_balance_view.dart';
import 'package:nowdelivery_user_app/view/widgets/wallet/my_cards_view.dart';
import 'package:nowdelivery_user_app/view/widgets/wallet/wallet_action_button.dart';
import 'package:nowdelivery_user_app/view/widgets/wallet/wallet_card_widget.dart';
import 'package:nowdelivery_user_app/view/widgets/wallet/wallet_history_item.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final Size screenSize = MediaQuery.sizeOf(context);
    return AppWavedScaffold(
      appBarTitle: LangKeys.walletKey.tr(),
      canPop: Navigator.canPop(context),
      body: Column(
        spacing: screenSize.height*0.03,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
              aspectRatio: 2,
              child: WalletCardWidget()),
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
                              maxHeight: screenHeight*0.6
                            ),
                            child: AddBalanceView()),
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
                                maxHeight: screenHeight*0.6
                            ),
                            child: MyCardsView()),
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
                                maxHeight: screenHeight*0.6
                            ),
                            child: AddCardView()),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              spacing: screenSize.height*0.015,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LangKeys.walletRecordKey.tr(),
                  style: AppTextStyles.style18SemiBold.copyWith(
                      color: colors.onSecondary,
                    fontSize: screenSize.width*0.04
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) => AspectRatio(
                        aspectRatio: 5.5,
                        child: WalletHistoryItem()),
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