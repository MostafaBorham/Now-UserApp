import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/wallet_payment_provider.dart';












class WalletPaymentRow extends ConsumerWidget {
  const WalletPaymentRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final bool selected = ref.watch(walletPaymentProvider);

    return Column(
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



                                NewPriceWidget(
                                  color: colors.neutral1200,
                                  size: 15,
                                  price: '150.00',
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
    );
  }
}



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
