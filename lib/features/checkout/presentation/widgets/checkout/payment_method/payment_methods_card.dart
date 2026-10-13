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

    // Selection: whatever the customer last tapped, else the default card —
    // the same card confirm sends (see [CheckoutModel.payingCard]).
    final CardPaymentModel? paying = CheckoutModel.payingCard(
      cards,
      ref.watch(selectedPaymentCardProvider),
    );
    final int selectedIndex = walletPays || paying == null
        ? -1
        : cards.indexOf(paying);

    final List<PaymentMethodEntry> methods = cards
        .map(
          (CardPaymentModel card) => (
            icon: _brandLogo(card, colors),
            color: colors.secondaryContainer,
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

  /// The Visa / Mastercard logo, as on the wallet screen; any other brand
  /// (Mada has no asset yet) keeps the generic card icon.
  Widget _brandLogo(CardPaymentModel card, AppColorScheme colors) {
    final String brand = (card.brand ?? '').toLowerCase();
    if (brand.contains('master')) {
      return Assets.media.images.svg.masterLogo.svg(width: 28);
    }
    if (brand.contains('visa')) {
      return Assets.media.images.svg.visaLogo.svg(width: 28);
    }
    return Icon(Icons.credit_card, size: 24, color: colors.secondaryContainer);
  }

  /// The cardholder name as the row title, as in the wallet's card list; the
  /// brand when there is no name, else a generic label.
  String _title(CardPaymentModel card) {
    final String name = (card.cardholderName ?? '').trim();
    if (name.isNotEmpty) return name;
    return displayCardBrand(card.brand) ?? LangKeys.paymentCardKey.tr();
  }

  /// The masked number the server sends (`•••• 4242`), or one built from the
  /// last four, or nothing when neither is present.
  String? _maskedNumber(CardPaymentModel card) {
    if (card.maskedNumber != null) return card.maskedNumber;
    if (card.lastFour != null) return '•••• ${card.lastFour}';
    return null;
  }
}
