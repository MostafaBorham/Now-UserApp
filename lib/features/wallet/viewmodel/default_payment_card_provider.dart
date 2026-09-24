import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/repo/wallet_repo.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';

/// The customer's current default payment card — and the one place that changes
/// it.
///
/// Unlike a derived provider, this holds its **own** state, resolved from
/// [getMyCardsProvider]rather than from a position in that list: the default is
/// the card the server marks `is_default`, falling back to the first *usable*
/// one (see [CardPaymentModel.isUsable]).
///
/// It keeps following the list rather than seeding once, because the chosen card
/// can stop existing underneath it — a delete makes the server promote a new
/// default, and that must land here too, or the next top-up would charge a card
/// that is gone. A deliberate choice is still preserved: while the selected card
/// is still present and usable it is left alone, so an ordinary refetch never
/// moves the selection (see [DefaultPaymentCardViewModel._applyCards]).
///
/// [DefaultPaymentCardViewModel.setPaymentCardDefault] is the only mutator that
/// asks the server ([DefaultPaymentCardViewModel.adopt] only takes a card the
/// server already made default): it talks to the repo directly, and only on a
/// confirmed server success does it
/// flip its own state to the new card and ask [getMyCardsProvider] to refetch
/// from the repo — so the cards list re-syncs from the source of truth without
/// ever modifying this provider.
///
/// The state is an [AsyncValue] so the my-cards sheet can drive its blocking
/// overlay off `isLoading` and surface the failure message; the retained
/// previous value keeps `valueOrNull` pointing at the last good default even
/// while an attempt is in flight or after it fails.
final defaultPaymentCardProvider = StateNotifierProvider<
    DefaultPaymentCardViewModel, AsyncValue<CardPaymentModel?>>(
  (Ref ref) => DefaultPaymentCardViewModel(ref),
);

class DefaultPaymentCardViewModel
    extends StateNotifier<AsyncValue<CardPaymentModel?>> {
  DefaultPaymentCardViewModel(this._ref)
      : super(const AsyncValue<CardPaymentModel?>.data(null)) {
    _followCards();
  }

  final Ref _ref;
  final WalletRepo _repo = WalletRepo();
  ProviderSubscription<AsyncValue<List<CardPaymentModel>>>? _cardsSub;

  @override
  void dispose() {
    _cardsSub?.close();
    _repo.cancelRequests();
    super.dispose();
  }

  /// Resolves the default from the cards already loaded (synchronously, if there
  /// are any) and keeps following [getMyCardsProvider] for every later change.
  void _followCards() {
    _applyCards(_ref.read(getMyCardsProvider).valueOrNull);

    _cardsSub = _ref.listen<AsyncValue<List<CardPaymentModel>>>(
      getMyCardsProvider,
      (AsyncValue<List<CardPaymentModel>>? _,
              AsyncValue<List<CardPaymentModel>> next) =>
          _applyCards(next.valueOrNull),
    );
  }

  /// Reconciles the held default against a freshly loaded [cards] list.
  ///
  /// A selection the customer made is preserved: while the held card is still
  /// present and usable, it stays selected (refreshed to the server's copy so
  /// its flags track reality) and an ordinary refetch moves nothing. Only when
  /// it has gone — deleted, expired, or no longer returned — is the default
  /// re-resolved, which is what keeps a deleted card from being charged.
  ///
  /// A `null` [cards] (the list loading or failed) changes nothing.
  void _applyCards(List<CardPaymentModel>? cards) {
    if (cards == null) return;

    final int? heldId = state.valueOrNull?.id;
    if (heldId != null) {
      for (final CardPaymentModel card in cards) {
        if (card.id == heldId && card.isUsable) {
          state = AsyncValue<CardPaymentModel?>.data(card);
          return;
        }
      }
    }

    state = AsyncValue<CardPaymentModel?>.data(_resolveDefault(cards));
  }

  /// The card that should fund a top-up: the one the server marks `is_default`,
  /// else the first usable one. Only usable cards are considered
  /// ([CardPaymentModel.isUsable]) — the server rejects the rest, so preselecting
  /// one would guarantee a failed charge. `null` when nothing qualifies.
  ///
  /// Resolved from the flag rather than list position: the server happens to
  /// return the default first today, but relying on that ordering means the app
  /// charges whatever sits at index 0 the day it changes.
  static CardPaymentModel? _resolveDefault(List<CardPaymentModel> cards) {
    CardPaymentModel? firstUsable;

    for (final CardPaymentModel card in cards) {
      if (!card.isUsable) continue;
      if (card.isDefault ?? false) return card;
      firstUsable ??= card;
    }

    return firstUsable;
  }

  /// Takes [card] as the default without a request — for a card the server
  /// just made default itself (added with `set_default`). Only a usable card
  /// is taken, the same rule [_applyCards] follows.
  void adopt(CardPaymentModel card) {
    if (card.isUsable) state = AsyncValue<CardPaymentModel?>.data(card);
  }

  /// Marks the card [id] as the default. Talks to the repo directly; only on a
  /// confirmed server success does it flip its own state to [id]'s card and ask
  /// [getMyCardsProvider] to refetch from the repo. On failure it keeps the
  /// previous default (retained through the error) and returns the message so
  /// the caller can surface it and dismiss the sheet.
  ///
  /// On success `state` becomes `data(card)` and `null` is returned; on failure
  /// `state` becomes an error over the previous value and the message is
  /// returned.
  Future<String?> setPaymentCardDefault(int id) async {
    state =
        const AsyncValue<CardPaymentModel?>.loading().copyWithPrevious(state);

    final Either<Failure, CardPaymentModel> result =
        await _repo.setPaymentCardDefault(id);

    if (!mounted) return null;

    return result.fold(
      (Failure failure) {
        state = AsyncValue<CardPaymentModel?>.error(
          failure.message,
          StackTrace.current,
        ).copyWithPrevious(state);
        return failure.message;
      },
      (CardPaymentModel card) {
        state = AsyncValue<CardPaymentModel?>.data(card);
        // Confirmed by the server: re-sync the cards list from the repo. The
        // refetch lands back in [_applyCards], which finds this card still
        // present and usable and so leaves the selection exactly here.
        _ref.read(getMyCardsProvider.notifier).getMyCards();
        return null;
      },
    );
  }
}
