import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';

import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/money_amount_picker.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_info_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_transactions_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/top_up_wallet_vm.dart';

class AddBalanceView extends ConsumerStatefulWidget {
  const AddBalanceView({super.key, this.walletModel});

  final WalletModel? walletModel;

  @override
  ConsumerState<AddBalanceView> createState() => _AddBalanceViewState();
}

class _AddBalanceViewState extends ConsumerState<AddBalanceView> {
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


  int? _parseAmount(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw) ?? double.tryParse(raw)?.round();
  }

  Future<void> _onContinue() async {
    final int? amount = _parseAmount(moneyAmount);
    if (amount == null) return;





    final List<CardPaymentModel>? cards =
        ref.read(getMyCardsProvider).valueOrNull;
    if (cards == null || cards.isEmpty) {



      AppToast.showError(context, LangKeys.selectPaymentMethodFirstKey.tr());
      return;
    }



    final String? error = await ref
        .read(topUpWalletProvider.notifier)
        .topUpWallet(amount: amount);

    if (!mounted) return;

    if (error != null) {


      AppToast.showError(context, error);
      return;
    }


    ref.read(getWalletInfoProvider.notifier).getWalletInfo();
    ref.read(getWalletTransactionsProvider.notifier).loadFirstPage();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    final bool isSubmitting = ref.watch(topUpWalletProvider).isLoading;



    return PopScope(
      canPop: !isSubmitting,
      child: Padding(
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
                  IconButton(
                    padding: EdgeInsetsGeometry.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: isSubmitting
                        ? null
                        : () {
                            context.pop();
                          },
                    icon: Icon(Icons.clear, size: 20, color: colors.black),
                  ),
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
                        maxAmount: widget.walletModel?.maximum,
                        options: widget.walletModel?.suggestedAmounts
                            .map((amount) => formatDouble(amount).toString())
                            .toList(),
                        onAmountChanged: (amount) {
                          moneyAmount = amount;
                          setState(() {});
                          debugPrint('selected amount ==== $amount');
                        },
                        onOtherSelected: _scrollToEnd,
                      ),
                    ],
                  ),
                ),
              ),
              5.hSpace,
              PrimaryAppButton(
                title: LangKeys.topUpKey.tr(),
                isLoading: isSubmitting,
                isDisabled: moneyAmount == null || moneyAmount!.isEmpty,
                onTap: _onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
