import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';

import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/money_amount_picker.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/default_payment_card_provider.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_info_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_transactions_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/top_up_wallet_vm.dart';

class AddBalanceView extends ConsumerStatefulWidget {
  const AddBalanceView({super.key});

  @override
  ConsumerState<AddBalanceView> createState() => _AddBalanceViewState();
}

class _AddBalanceViewState extends ConsumerState<AddBalanceView> {
  /// The chosen amount in whole halalas, or null while nothing submittable is
  /// entered.
  int? amountHalalas;
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

  Future<void> _onContinue() async {
    final int? amount = amountHalalas;
    if (amount == null) return;

    // While this awaits, the sheet is watching `topUpWalletProvider` so the
    // button spins and `PopScope` blocks every dismissal path. There is no card
    // check here: the button is disabled until a chargeable card resolves, and
    // the view model refuses the call outright if one somehow doesn't.
    final String? error = await ref
        .read(topUpWalletProvider.notifier)
        .topUpWallet(amountHalalas: amount);

    if (!mounted) return;

    if (error != null) {
      // Surface the error and keep the sheet open so the customer can retry; the
      // toast floats on the root overlay, above the sheet.
      AppToast.showError(context, error);
      // No answer came back, so the top-up may have landed: reload the balance
      // and history behind the sheet so it shows if it did.
      if (error == LangKeys.topUpUnconfirmedKey) {
        ref.read(getWalletInfoProvider.notifier).getWalletInfo();
        ref.read(getWalletTransactionsProvider.notifier).refresh();
      }
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

    // The funding limits are watched rather than snapshotted at open time, so a
    // wallet fetch that lands while the sheet is up fills the chips in. Both
    // limits must be present: without them there is nothing to validate an
    // amount against, and inventing a ceiling only produces amounts the server
    // rejects — so the sheet waits instead of guessing.
    final WalletModel? wallet = ref.watch(getWalletInfoProvider).valueOrNull;
    final double? minimum = wallet?.minimum;
    final double? maximum = wallet?.maximum;
    final bool hasLimits = minimum != null && maximum != null;

    // Topping up charges a card, so the button stays disabled until one has
    // resolved — a list that is empty, still loading, or holds only expired
    // cards all leave this null.
    final CardPaymentModel? fundingCard =
        ref.watch(defaultPaymentCardProvider).valueOrNull;

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
                      if (hasLimits)
                        MoneyAmountPicker(
                          minAmountHalalas: sarDoubleToHalalas(minimum),
                          maxAmountHalalas: sarDoubleToHalalas(maximum),
                          options: wallet?.suggestedAmounts,
                          onAmountChanged: (int? amount) {
                            setState(() => amountHalalas = amount);
                          },
                          onOtherSelected: _scrollToEnd,
                        ),
                    ],
                  ),
                ),
              ),
              5.hSpace,
              // Without a card that can be charged, Top up stayed disabled
              // with no reason (QA-003 A17).
              if (hasLimits && fundingCard == null) ...[
                Text(
                  LangKeys.topUpNeedsCardKey.tr(),
                  overflow: TextOverflow.visible,
                  style: AppTextStyles.style12Medium.copyWith(
                    color: context.colors.neutral500,
                  ),
                ),
                5.hSpace,
              ],
              PrimaryAppButton(
                title: LangKeys.topUpKey.tr(),
                isLoading: isSubmitting,
                // A valid amount, real limits to have validated it against, and
                // a card that can actually be charged — all three, before the
                // customer can submit anything.
                isDisabled:
                    amountHalalas == null || !hasLimits || fundingCard == null,
                onTap: _onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
