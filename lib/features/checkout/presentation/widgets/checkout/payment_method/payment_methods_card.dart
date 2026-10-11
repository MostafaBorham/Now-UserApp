import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/payment_methods_radio_group.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/selected_payment_card_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/wallet_payment_provider.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';

/// A soft grey card that lists the customer's saved cards (from the checkout
/// preview) with a single (radio-style) selection, followed by an "Add New
/// Card" outlined button.
///
/// This is the populated half of the payment section — [CheckoutPaymentSection]
/// swaps it for the red "choose a method" prompt when the customer has no card.
///
/// The picked card id is published to [selectedPaymentCardProvider]; the confirm
/// step reads it and sends `payment_method: card` + `payment_method_id` when the
/// wallet is unticked. Selection defaults to the server-marked default card.
class PaymentMethodsCard extends ConsumerWidget {
  const PaymentMethodsCard({
    super.key,
    required this.cards,
    required this.onAddCard,
  });

  final List<CardPaymentModel> cards;

  /// Opens the add-card screen (and brings the new card in on return).
  final VoidCallback onAddCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;

    // Only one method pays: while the wallet is ticked no card is selected and
    // the list is greyed out. Tapping a card switches to it.
    final bool walletPays = ref.watch(
      walletUseProvider.select((WalletUse use) => use != WalletUse.off),
    );

    // Selection: whatever the customer last tapped, else the default card. The
    // index feeds the radio group; a stale/unknown id lands on the first card.
    final int? defaultId = CheckoutModel.resolveDefaultCard(cards)?.id;
    final int? selectedId = ref.watch(selectedPaymentCardProvider) ?? defaultId;
    final int matchedIndex = cards.indexWhere(
      (CardPaymentModel card) => card.id == selectedId,
    );
    final int selectedIndex = walletPays
        ? -1
        : matchedIndex < 0
        ? 0
        : matchedIndex;

    final List<PaymentMethodEntry> methods = cards
        .map(
          (CardPaymentModel card) => (
            icon: Icons.credit_card,
            color: colors.secondaryContainer,
            solid: false,
            title: _title(card),
            subtitle: _maskedNumber(card),
          ),
        )
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
        borderRadius: AppBorderRadius.brCircular8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Text(
            LangKeys.paymentMethodKey.tr(),
            style: AppTextStyles.style16Medium.copyWith(
              color: colors.tertiaryContainer,
            ),
          ),
          Opacity(
            opacity: walletPays ? 0.5 : 1,
            child: PaymentMethodsRadioGroup(
              methods: methods,
              selectedIndex: selectedIndex,
              onChanged: (int index) {
                ref.read(selectedPaymentCardProvider.notifier).state =
                    cards[index].id;
                ref.read(walletPaymentProvider.notifier).state = false;
              },
            ),
          ),
          InkWell(
            onTap: onAddCard,
            borderRadius: AppBorderRadius.brCircular8,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              decoration: BoxDecoration(
                color: colors.white,
                borderRadius: AppBorderRadius.brCircular8,
                border: Border.all(color: colors.neutral200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Assets.media.images.svg.circleAddMoreBrokenIcon.svg(),
                  Text(
                    LangKeys.addNewCardKey.tr(),
                    style: AppTextStyles.style16Medium.copyWith(
                      color: colors.neutral1200,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The brand (capitalised) as the row title, falling back to a generic label.
  String _title(CardPaymentModel card) {
    final String brand = (card.brand ?? '').trim();
    if (brand.isEmpty) return LangKeys.paymentCardKey.tr();
    return brand[0].toUpperCase() + brand.substring(1);
  }

  /// The masked number the server sends (`•••• 4242`), or one built from the
  /// last four, or nothing when neither is present.
  String? _maskedNumber(CardPaymentModel card) {
    if (card.maskedNumber != null) return card.maskedNumber;
    if (card.lastFour != null) return '•••• ${card.lastFour}';
    return null;
  }
}
