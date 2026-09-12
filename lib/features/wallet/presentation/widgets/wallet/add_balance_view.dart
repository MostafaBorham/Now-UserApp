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

  /// Parses the picker's amount string into the whole number the API expects.
  int? _parseAmount(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw) ?? double.tryParse(raw)?.round();
  }

  Future<void> _onContinue() async {
    final int? amount = _parseAmount(moneyAmount);
    if (amount == null) return;

    // Topping up charges a saved card, so there must be one to charge. Gate the
    // top-up on the shared cards list: only proceed once it has resolved with a
    // non-empty list — otherwise there is no payment method, so surface a
    // message and stop before hitting the top-up flow.
    final List<CardPaymentModel>? cards =
        ref.read(getMyCardsProvider).valueOrNull;
    if (cards == null || cards.isEmpty) {
      // No saved card to charge: surface the error and keep the sheet open so the
      // customer can act on it. The toast floats on the root overlay, above the
      // sheet.
      AppToast.showError(context, LangKeys.selectPaymentMethodFirstKey.tr());
      return;
    }

    // While this awaits, the sheet is watching `topUpWalletProvider` so the
    // button spins and `PopScope` blocks every dismissal path.
    final String? error = await ref
        .read(topUpWalletProvider.notifier)
        .topUpWallet(amount: amount);

    if (!mounted) return;

    if (error != null) {
      // Surface the error and keep the sheet open so the customer can retry; the
      // toast floats on the root overlay, above the sheet.
      AppToast.showError(context, error);
      return;
    }

    // Success: pull the new balance and the fresh history, then close the sheet.
    ref.read(getWalletInfoProvider.notifier).getWalletInfo();
    ref.read(getWalletTransactionsProvider.notifier).loadFirstPage();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    final bool isSubmitting = ref.watch(topUpWalletProvider).isLoading;

    // Lift the whole sheet above the keyboard; the sheet grows by the keyboard
    // height (up to its max), then the middle area scrolls once capped.
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
