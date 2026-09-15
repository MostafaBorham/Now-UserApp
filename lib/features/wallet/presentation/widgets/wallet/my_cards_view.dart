import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/enums/online_card_types.dart';
import 'package:nowdelivery_user_app/core/params/online_card_params.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/blocking_loading_overlay.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/online_card_radio_selector.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/online_card_radio_selector_item_shimmer.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/delete_payment_card_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/default_payment_card_provider.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';









class MyCardsView extends ConsumerWidget {
  const MyCardsView({super.key});




  static const double _cardRowHeight = 74;
  static const double _cardRowGap = 10;
  static const int _visibleCards = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;





    const double cardsAreaHeight =
        _cardRowHeight * _visibleCards + _cardRowGap * (_visibleCards - 1);
    final AsyncValue<List<CardPaymentModel>> cardsState = ref.watch(
      getMyCardsProvider,
    );






    ref.listen<AsyncValue<void>>(deletePaymentCardProvider, (
      AsyncValue<void>? previous,
      AsyncValue<void> next,
    ) {
      if (next.hasError && !next.isLoading) {
        AppToast.showError(context, next.error.toString());
      }
    });





    ref.listen<AsyncValue<CardPaymentModel?>>(defaultPaymentCardProvider, (
      AsyncValue<CardPaymentModel?>? previous,
      AsyncValue<CardPaymentModel?> next,
    ) {
      if (previous?.isLoading != true) return;
      if (next.hasError && !next.isLoading) {
        AppToast.showError(context, next.error.toString());
      }
    });





    final bool isSettingDefault =
        ref.watch(defaultPaymentCardProvider).isLoading;
    final bool isDeleting = ref.watch(deletePaymentCardProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 10,
            children: [
              AutoSizeText(
                LangKeys.myCardsKey.tr(),
                style: AppTextStyles.style18Medium.copyWith(
                  color: colors.black,
                ),
              ),
              IconButton(
                padding: EdgeInsetsGeometry.zero,
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  context.pop();
                },
                icon: Icon(Icons.clear, size: 20, color: colors.black),
              ),
            ],
          ),






          SizedBox(
            height: cardsAreaHeight,
            child: BlockingLoadingOverlay(
              isLoading: isSettingDefault || isDeleting,
              child: cardsState.when(
                loading: () => ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _visibleCards,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: _cardRowGap),
                  itemBuilder: (context, index) =>
                      const OnlineCardRadioSelectorItemShimmer(),
                ),
                error: (Object error, _) => ServerConnectionErrorWidget(
                  message: error.toString(),
                  onRetry: () =>
                      ref.read(getMyCardsProvider.notifier).getMyCards(),
                ),
                data: (List<CardPaymentModel> cards) => cards.isEmpty
                    ? Center(
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 12,
                        children: [
                          Icon(
                            Icons.credit_card_off_outlined,
                            size: 64,
                            color: colors.neutral500,
                          ),
                          Text(
                            LangKeys.noCardsYetKey.tr(),
                            style: AppTextStyles.style18Medium.copyWith(
                              color: colors.neutral500,
                            ),
                          ),
                        ],
                      ))
                    : OnlineCardRadioSelector(
                      cards: cards
                          .map(
                            (CardPaymentModel card) => OnlineCardParams(
                              id: card.id,
                              cardHolder: card.cardholderName ?? '',
                              cardNumber:
                                  card.maskedNumber ?? card.lastFour ?? '',
                              cardType:
                                  (card.brand?.toLowerCase().contains(
                                        'master',
                                      ) ??
                                      false)
                                  ? OnlineCardTypes.master
                                  : OnlineCardTypes.visa,
                              isDefault: card.isDefault ?? false,
                            ),
                          )
                          .toList(),
                      onCardSelected: (card) {


                        final int? id = card.id;
                        if (card.isDefault || id == null) return;
                        ref
                            .read(defaultPaymentCardProvider.notifier)
                            .setPaymentCardDefault(id);
                      },
                      onDeleteCard: (card) {


                        final int? id = card.id;
                        if (id == null) return;
                        ref
                            .read(deletePaymentCardProvider.notifier)
                            .deletePaymentCard(id);
                      },
                    ),
              ),
            ),
          ),
          5.hSpace,
          PrimaryAppButton(
            title: LangKeys.addNewCardKey.tr(),
            onTap: () => context.pushNamed(AppRoutes.addPaymentCard),
          ),
        ],
      ),
    );
  }
}
