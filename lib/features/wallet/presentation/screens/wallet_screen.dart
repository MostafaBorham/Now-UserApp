import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
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

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int? _selectedActionIndex;

  Future<void> _openActionSheet({
    required int index,
    required Widget sheet,
    required double maxHeight,
    required Color backgroundColor,
    bool isScrollControlled = false,
  }) async {
    setState(() => _selectedActionIndex = index);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: sheet,
      ),
    );
    if (!mounted) return;
    setState(() => _selectedActionIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      body: AppWavedView(
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
                      isSelected: _selectedActionIndex == 0,
                      onTap: () => _openActionSheet(
                        index: 0,
                        sheet: AddBalanceView(),
                        maxHeight: screenHeight * 0.9,
                        backgroundColor: colors.white,
                        isScrollControlled: true,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 3,
                    child: WalletActionButton(
                      actionName: LangKeys.myCardsKey.tr(),
                      isSelected: _selectedActionIndex == 1,
                      onTap: () => _openActionSheet(
                        index: 1,
                        sheet: MyCardsView(),
                        maxHeight: screenHeight * 0.6,
                        backgroundColor: colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 3,
                    child: WalletActionButton(
                      actionName: LangKeys.addCardKey.tr(),
                      isSelected: _selectedActionIndex == 2,
                      onTap: () => _openActionSheet(
                        index: 2,
                        sheet: AddCardView(),
                        maxHeight: screenHeight * 0.75,
                        backgroundColor: colors.white,
                        isScrollControlled: true,
                      ),
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
                      color: colors.black,
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
      ),
    );
  }
}
