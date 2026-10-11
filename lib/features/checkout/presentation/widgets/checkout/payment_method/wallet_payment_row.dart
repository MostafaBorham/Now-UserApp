import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/wallet_payment_provider.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_info_vm.dart';

/// The wallet payment option, shown under the payment methods section: the
/// balance with a checkbox (see [walletUseProvider] for when it starts ticked),
/// and — while it is ticked and the balance can't cover the total — a note
/// saying to pay by card or top up.
class WalletPaymentRow extends ConsumerWidget {
  const WalletPaymentRow({super.key});

  /// Opens the wallet to top up, and re-checks the balance on the way back.
  Future<void> _topUp(BuildContext context, WidgetRef ref) async {
    await context.pushNamed(AppRoutes.walletScreen);
    if (context.mounted) {
      ref.read(getWalletInfoProvider.notifier).getWalletInfo();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final WalletUse use = ref.watch(walletUseProvider);
    final bool selected = use != WalletUse.off;

    // Checkout refetches this on open, and the last balance stays while that
    // loads. Whatever the state, the row stays — it is the payment choice, and
    // hiding it is what 05e26eb fixed: a ticked wallet with no row would leave
    // no way to pay by card. With no balance yet the amount shimmers, and
    // after a failure (or a balance only the offline cache had) a line says it
    // may be out of date, with a retry.
    final AsyncValue<WalletModel> walletState = ref.watch(
      getWalletInfoProvider,
    );
    final double? balance = walletState.valueOrNull?.balance;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
        borderRadius: AppBorderRadius.brCircular12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          InkWell(
            onTap: () =>
                ref.read(walletPaymentProvider.notifier).state = !selected,
            borderRadius: AppBorderRadius.brCircular12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.primaryFixed,
                borderRadius: AppBorderRadius.brCircular12,
              ),
              child: Row(
                spacing: 12,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primary100,
                      shape: BoxShape.circle,
                    ),
                    child: Assets.media.images.svg.wallet2.svg(
                      width: 24,
                      height: 24,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                LangKeys.walletKey.tr(),
                                style: AppTextStyles.style16Medium.copyWith(
                                  color: colors.tertiaryContainer,
                                ),
                              ),
                              Row(
                                spacing: 4,
                                children: [
                                  Text(
                                    LangKeys.balanceKey.tr(),
                                    style: AppTextStyles.style14Regular
                                        .copyWith(color: colors.neutral500),
                                  ),
                                  if (balance != null)
                                    NewPriceWidget(
                                      color: colors.neutral1200,
                                      size: 15,
                                      price: formatMoney(balance),
                                    )
                                  else if (walletState.isLoading)
                                    AppShimmer(
                                      child: Container(
                                        width: 60,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: colors.black,
                                          borderRadius:
                                              AppBorderRadius.brCircular4,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (walletState.hasError)
                                _StaleBalance(
                                  isRetrying: walletState.isLoading,
                                  onRetry: () => ref
                                      .read(getWalletInfoProvider.notifier)
                                      .getWalletInfo(),
                                ),
                            ],
                          ),
                        ),
                        _WalletCheckbox(selected: selected),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (use == WalletUse.short)
            _ShortfallNote(
              shortfall: formatHalalasAsSar(
                walletShortfallHalalas(
                      walletState.valueOrNull,
                      ref.watch(checkoutTotalProvider),
                    ) ??
                    0,
              ),
              onTopUp: () => _topUp(context, ref),
            ),
        ],
      ),
    );
  }
}

/// The square tick that marks the wallet as a payment method: filled green when
/// on, an empty outlined box when off.
class _WalletCheckbox extends StatelessWidget {
  const _WalletCheckbox({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? colors.primary500Main : Colors.transparent,
        borderRadius: AppBorderRadius.brCircular4,
        border: selected
            ? null
            : Border.all(color: colors.neutral200, width: 1.5),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: 12, color: colors.white)
          : null,
    );
  }
}

/// "Balance is not up to date" with a retry icon, under the balance when the
/// last fetch failed; a small spinner replaces the icon while retrying.
class _StaleBalance extends StatelessWidget {
  const _StaleBalance({required this.isRetrying, required this.onRetry});

  final bool isRetrying;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Row(
      spacing: 4,
      children: [
        Flexible(
          child: Text(
            LangKeys.walletBalanceNotUpdatedKey.tr(),
            style: AppTextStyles.style12Regular.copyWith(color: colors.red400),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isRetrying ? null : onRetry,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: isRetrying
                ? SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.red400,
                    ),
                  )
                : Assets.media.images.svg.retryIcon.svg(
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(
                      colors.red400,
                      BlendMode.srcIn,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// The hint under the wallet row: the balance can't cover this order, so the
/// wallet has to be unticked for a card to pay, or topped up.
class _ShortfallNote extends StatelessWidget {
  const _ShortfallNote({required this.shortfall, required this.onTopUp});

  /// How much the wallet is short, formatted.
  final String shortfall;
  final VoidCallback onTopUp;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primaryFixed,
        borderRadius: AppBorderRadius.brCircular8,
        border: Border.all(color: colors.neutral200),
      ),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LangKeys.walletShortfallHintKey.tr(
                    namedArgs: <String, String>{'amount': shortfall},
                  ),
                  // Every `AppTextStyles` entry carries
                  // `TextOverflow.ellipsis`, and an ellipsis with no
                  // `maxLines` collapses the paragraph to one line — the hint
                  // has to opt out to wrap in full.
                  overflow: TextOverflow.visible,
                  style: AppTextStyles.style12Regular.copyWith(
                    color: colors.neutral500,
                    height: 1.5,
                  ),
                ),
                InkWell(
                  onTap: onTopUp,
                  borderRadius: AppBorderRadius.brCircular4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      LangKeys.topUpKey.tr(),
                      style: AppTextStyles.style14Medium.copyWith(
                        color: colors.primary500Main,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.secondaryContainer.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Assets.media.images.svg.infoBlue.svg(width: 16, height: 16),
          ),
        ],
      ),
    );
  }
}
