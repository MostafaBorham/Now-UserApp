import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/wallet_payment_provider.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_info_vm.dart';

/// The wallet payment option, shown under the payment methods section: the
/// balance with a checkbox that is ticked by default, and — while it is ticked
/// — a note explaining that the method picked above only covers the shortfall.
///
/// The note hangs off the checkbox rather than off a balance-vs-total
/// comparison: it is guidance about how the wallet is charged, which stops
/// being true the moment the wallet is switched off.
class WalletPaymentRow extends ConsumerWidget {
  const WalletPaymentRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final bool selected = ref.watch(walletPaymentProvider);

    // The session already fetched this (see `AuthSessionViewModel`), so on a
    // normal checkout the balance is in memory and renders on the first frame.
    // Null covers both loading and error: the row stays — it is the payment
    // choice, and hiding it is what 05e26eb fixed — but the amount is left off
    // rather than guessed, matching how `WalletCardWidget` treats a null
    // balance.
    final double? balance =
        ref.watch(getWalletInfoProvider).valueOrNull?.balance;

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
                                      price: '${formatDouble(balance)}',
                                    ),
                                ],
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
          if (selected) const _ShortfallNote(),
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

/// The hint under the wallet row: a second payment method takes over whatever
/// the balance cannot cover.
class _ShortfallNote extends StatelessWidget {
  const _ShortfallNote();

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
            child: Text(
              LangKeys.walletShortfallHintKey.tr(),
              // Every `AppTextStyles` entry carries `TextOverflow.ellipsis`,
              // and an ellipsis with no `maxLines` collapses the paragraph to
              // one line — the hint has to opt out to wrap in full.
              overflow: TextOverflow.visible,
              style: AppTextStyles.style12Regular.copyWith(
                color: colors.neutral500,
                height: 1.5,
              ),
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
