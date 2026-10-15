import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/add_card_view.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/add_balance_view.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/my_cards_view.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/wallet_action_button.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/wallet_card_widget.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/wallet_transactions_view.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_info_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_transactions_vm.dart';

/// What the wallet opens on, passed as the route's `extra`.
enum WalletEntryAction {
  /// Straight into the add-balance sheet: checkout's "top up" link, where the
  /// customer came to add money, not to browse the wallet.
  addBalance,
}

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key, this.entryAction});

  final WalletEntryAction? entryAction;

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  int? _selectedActionIndex;

  @override
  void initState() {
    super.initState();
    // The balance changes outside the app (refunds, credits, orders paid from
    // the wallet), so it is fetched fresh each time the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(getWalletInfoProvider.notifier).getWalletInfo();
      if (widget.entryAction == WalletEntryAction.addBalance) {
        _openAddBalance();
      }
    });
  }

  void _openAddBalance() {
    // Top-up charges the default card, which follows the cards list — no
    // longer loaded at boot, so fetch it fresh here before the sheet needs a
    // funding card.
    ref.read(getMyCardsProvider.notifier).getMyCards();
    _openActionSheet(
      index: 0,
      // No wallet snapshot passed in: the sheet watches the provider itself,
      // so limits and suggested amounts that arrive while it is open still
      // reach it.
      sheet: const AddBalanceView(),
      maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      backgroundColor: context.colors.white,
      isScrollControlled: true,
      // The sheet blocks dismissal while a top-up is in flight via PopScope;
      // drag-to-dismiss would bypass it, so it's disabled — the X button /
      // barrier remain.
      enableDrag: false,
    );
  }

  Future<void> _refresh() => Future.wait<void>(<Future<void>>[
    ref.read(getWalletInfoProvider.notifier).getWalletInfo(),
    ref.read(getWalletTransactionsProvider.notifier).loadFirstPage(),
  ]);

  Future<void> _openActionSheet({
    required int index,
    required Widget sheet,
    required double maxHeight,
    required Color backgroundColor,
    bool isScrollControlled = false,
    bool enableDrag = true,
  }) async {
    setState(() => _selectedActionIndex = index);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
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

    // The balance card and the three action buttons stay on screen in every
    // state of the wallet-info fetch; only the balance shown in the card follows
    // the provider — it arrives once the state turns to data (null until then),
    // and a refresh keeps the last one. The transaction history below owns its
    // own loading / error / data states, inside WalletTransactionsView.
    //
    // Pulling down anywhere — the card or the history — reloads both. The
    // screen is made scrollable at exactly its own height so the card area can
    // be pulled too, and the broad predicate lets the history list's own pull
    // reach this indicator; the list's built-in pull-to-refresh is off.
    final AsyncValue<WalletModel> infoState = ref.watch(getWalletInfoProvider);

    return Scaffold(
      body: AppWavedView(
        appBarTitle: LangKeys.walletKey.tr(),
        canPop: context.canPop(),
        body: AppRefreshIndicator(
          onRefresh: _refresh,
          notificationPredicate: (_) => true,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: constraints.maxHeight,
                child: Column(
                  spacing: screenSize.height * 0.03,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 2,
                      child: WalletCardWidget(
                        balance: infoState.valueOrNull?.balance,
                        // A cached balance still shows; the retry icon only takes the
                        // pill when there is no balance at all.
                        onReload:
                            infoState.hasError &&
                                !infoState.hasValue &&
                                !infoState.isLoading
                            ? () => ref
                                  .read(getWalletInfoProvider.notifier)
                                  .getWalletInfo()
                            : null,
                      ),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 3,
                            child: WalletActionButton(
                              actionName: LangKeys.addBalanceKey.tr(),
                              isSelected: _selectedActionIndex == 0,
                              onTap: _openAddBalance,
                            ),
                          ),
                        ),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 3,
                            child: WalletActionButton(
                              actionName: LangKeys.myCardsKey.tr(),
                              isSelected: _selectedActionIndex == 1,
                              onTap: () {
                                // Fetch the cards fresh from the backend every time the
                                // sheet is opened (they are no longer loaded at boot).
                                // The sheet renders the provider's loading/error/data
                                // states, so it shows the shimmer while this lands.
                                ref
                                    .read(getMyCardsProvider.notifier)
                                    .getMyCards();
                                _openActionSheet(
                                  index: 1,
                                  sheet: MyCardsView(),
                                  // The sheet sizes to its content and only grows to
                                  // this cap (80% of the screen), past which the cards
                                  // list scrolls inside it — so short lists leave no
                                  // dead space below them. isScrollControlled lets it
                                  // exceed the default half-screen ceiling to reach it.
                                  maxHeight: screenHeight * 0.8,
                                  backgroundColor: colors.white,
                                  isScrollControlled: true,
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
                              isSelected: _selectedActionIndex == 2,
                              onTap: () {
                                // Loaded so a card already saved is caught
                                // before it is sent again (BUG-014, QA V2).
                                ref
                                    .read(getMyCardsProvider.notifier)
                                    .getMyCards();
                                _openActionSheet(
                                  index: 2,
                                  sheet: AddCardView(),
                                  maxHeight: screenHeight * 0.75,
                                  backgroundColor: colors.white,
                                  isScrollControlled: true,
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
                              color: colors.black,
                              fontSize: screenSize.width * 0.04,
                            ),
                          ),
                          Expanded(child: WalletTransactionsView()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
