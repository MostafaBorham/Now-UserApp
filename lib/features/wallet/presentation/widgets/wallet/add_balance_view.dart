import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';

import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/money_amount_picker.dart';

class AddBalanceView extends StatefulWidget {
  const AddBalanceView({super.key});

  @override
  State<AddBalanceView> createState() => _AddBalanceViewState();
}

class _AddBalanceViewState extends State<AddBalanceView> {
  String? moneyAmount;
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    // Lift the whole sheet above the keyboard; the sheet grows by the keyboard
    // height (up to its max), then the middle area scrolls once capped.
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 30,
          left: 16,
          right: 16,
          bottom: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 10,
              children: [
                AutoSizeText(
                  LangKeys.addBalanceKey.tr(),
                  style: AppTextStyles.style18Medium.copyWith(
                    color: colors.black,
                  ),
                ),
                IconButton(padding: EdgeInsetsGeometry.zero,visualDensity: VisualDensity.compact, onPressed: () {
                  context.pop();
                }, icon: Icon(Icons.clear,size: 20,color: colors.black,))
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 15,
                  children: [
                    MoneyAmountPicker(
                      maxAmount: 5000,
                      onAmountChanged: (amount) {
                        moneyAmount = amount;
                        setState(() {

                        });
                        debugPrint('selected amount ==== $amount');
                      },
                      onOtherSelected: _scrollToEnd,
                    ),
                  ],
                ),
              ),
            ),
            5.hSpace,
            (moneyAmount!=null && moneyAmount!.isNotEmpty) ? PrimaryAppButton(title: LangKeys.continueKey.tr(),) : PrimaryAppDisabledButton(title: LangKeys.continueKey.tr())
          ],
        ),
      ),
    );
  }
}
