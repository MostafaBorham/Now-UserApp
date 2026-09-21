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
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/add_card_view.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/online_card_radio_selector.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/online_card_radio_selector_item_shimmer.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/delete_payment_card_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/default_payment_card_provider.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';

/// The my-cards bottom sheet: the customer's saved payment cards.
///
/// Watches [getMyCardsProvider] — the session-loaded, Hive-cached cards list
/// fired once on login by `AuthSessionViewModel` — and renders its [AsyncValue]:
/// a spinner while it loads, the shared error widget with retry on failure, the
/// empty-cards message when there are none, and the swipeable card selector once
/// they arrive. The list layer speaks in [OnlineCardParams], so each
/// [CardPaymentModel] is mapped across at the boundary.
class MyCardsView extends ConsumerWidget {
  const MyCardsView({super.key});

  /// A single saved-card row's height (18px vertical padding + its content) and
  /// the gap between rows. Four rows is exactly what the loading shimmer lays
  /// out — see [OnlineCardRadioSelectorItemShimmer].
  static const double _cardRowHeight = 74;
  static const double _cardRowGap = 10;
  static const int _visibleCards = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;

    // Pin the cards area to the height of the four shimmer rows, so the sheet
    // keeps one fixed height across every state: it does not jump taller for the
    // 4-row shimmer and then shorter for a couple of real cards. Fewer cards
    // leave empty space below; more than four scroll inside this fixed box.
    const double cardsAreaHeight =
        _cardRowHeight * _visibleCards + _cardRowGap * (_visibleCards - 1);
    final AsyncValue<List<CardPaymentModel>> cardsState = ref.watch(
      getMyCardsProvider,
    );

    // Delete runs under the same blocking overlay (below). A failure surfaces as
    // a snackbar; the swiped card has already sprung back into place, so nothing
    // else is needed. On success the delete VM refetches the list, so once the
    // overlay lifts it flips to loading and the sheet refreshes through the
    // shimmer with the card dropped out.
    ref.listen<AsyncValue<void>>(deletePaymentCardProvider, (
      AsyncValue<void>? previous,
      AsyncValue<void> next,
    ) {
      if (next.hasError && !next.isLoading) {
        AppToast.showError(context, next.error.toString());
      }
    });

    // Set-default runs under a blocking overlay (below); on failure the list is
    // left untouched, so surface the error and keep the sheet open (the toast
    // floats on the root overlay, above it). Guarding on "was loading" keeps the
    // initial data state from firing.
    ref.listen<AsyncValue<CardPaymentModel?>>(defaultPaymentCardProvider, (
      AsyncValue<CardPaymentModel?>? previous,
      AsyncValue<CardPaymentModel?> next,
    ) {
      if (previous?.isLoading != true) return;
      if (next.hasError && !next.isLoading) {
        AppToast.showError(context, next.error.toString());
      }
    });

    // Drives the overlay over the cards list while an in-place action is in
    // flight — setting the default or deleting. The default provider only enters
    // the loading state while a set-default is in flight (its seed is
    // synchronous), and the delete provider never loads on watch.
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
          // Fixed-height box (not Flexible): the cards area is always four rows
          // tall, so the sheet keeps one height whether the shimmer, a short
          // list, or the empty state is showing. The list scrolls inside it once
          // there are more than four cards. The overlay blocks the list while a
          // set-default / delete is in flight — the header and add-card button
          // below stay tappable.
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
                              isUsable: card.isUsable,
                            ),
                          )
                          .toList(),
                      onCardSelected: (card) {
                        // Already the default, never saved server-side, or
                        // expired (the server would reject the charge) —
                        // nothing to do.
                        final int? id = card.id;
                        if (card.isDefault || id == null || !card.isUsable) {
                          return;
                        }
                        ref
                            .read(defaultPaymentCardProvider.notifier)
                            .setPaymentCardDefault(id);
                      },
                      onDeleteCard: (card) {
                        // A card that was never saved server-side has no id —
                        // nothing to delete.
                        final int? id = card.id;
                        if (id == null) return;
                        ref
                            .read(deletePaymentCardProvider.notifier)
                            .deletePaymentCard(id);
                      },
                      onEditCard: (params) {
                        // Reopen the add-card sheet in edit mode for the tapped
                        // card, looked up from the loaded list by its id.
                        final int? id = params.id;
                        if (id == null) return;
                        final CardPaymentModel model = cards.firstWhere(
                          (CardPaymentModel c) => c.id == id,
                        );
                        AddCardView.show(context, card: model);
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
