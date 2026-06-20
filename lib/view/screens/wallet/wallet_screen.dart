import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/theme/app_gradient_colors.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/reverse_widget.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/show_more_items_header.dart';
import 'package:nowdelivery_user_app/view/widgets/wallet/wallet_action_button.dart';
import 'package:nowdelivery_user_app/view/widgets/wallet/wallet_card_widget.dart';
import 'package:nowdelivery_user_app/view/widgets/wallet/wallet_history_item.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return AppWavedScaffold(
      appBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: CircleAvatar(
                backgroundColor: colors.onPrimary,
                radius: 20.r,
                child: ReverseWidget(
                  child: Assets.media.images.svg.arrowBrokenIcon.svg(),
                ),
              ),
            ),
            AutoSizeText(
              'Wallet',
              style: AppTextStyles.style24SemiBold.copyWith(
                color: colors.onSecondary,
              ),
            ),
            20.wSpace,
          ],
        ),
      ),
      body: Column(
        spacing: 16,
        children: [
          WalletCardWidget(),
          Row(
            spacing: 5,
            children: [
              Expanded(child: WalletActionButton(actionName: 'Add Money')),
              Expanded(child: WalletActionButton(actionName: 'My Cards')),
              Expanded(child: WalletActionButton(actionName: 'Add Card')),
            ],
          ),
          10.hSpace,
          ShowMoreItemsHeader(headerTitle: 'Wallet History'),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) => WalletHistoryItem(),
              separatorBuilder: (context, index) => 12.hSpace,
              itemCount: 10,
            ),
          ),
        ],
      ),
    );
  }
}
