import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/repo/wallet_repo.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';

/// The customer's current default payment card — and the one place that changes
/// it.
///
/// Unlike a derived provider, this holds its **own** state. It is seeded **once**
/// — to the first card in [getMyCardsProvider] the moment that list first has
/// data — and from then on a cards refetch never writes back into it (see
/// [DefaultPaymentCardViewModel._seedOnce]); the provider owns the default.
///
/// [DefaultPaymentCardViewModel.setPaymentCardDefault] is the only mutator: it
/// talks to the repo directly, and only on a confirmed server success does it
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
    _seedOnce();
  }

  final Ref _ref;
  final WalletRepo _repo = WalletRepo();
  ProviderSubscription<AsyncValue<List<CardPaymentModel>>>? _seedSub;

  @override
  void dispose() {
    _seedSub?.close();
    _repo.cancelRequests();
    super.dispose();
  }

  /// Seeds the default to the first card in [getMyCardsProvider] the first time
  /// that list has data, then stops listening — so later cards fetches (the
  /// login refetch, the post-set-default refetch, a delete) never modify this
  /// provider. If the list is already loaded when this VM is created, it seeds
  /// synchronously and never listens at all.
  void _seedOnce() {
    final List<CardPaymentModel>? loaded =
        _ref.read(getMyCardsProvider).valueOrNull;
    if (loaded != null) {
      state = AsyncValue<CardPaymentModel?>.data(
        loaded.isEmpty ? null : loaded.first,
      );
      return;
    }

    _seedSub = _ref.listen<AsyncValue<List<CardPaymentModel>>>(
      getMyCardsProvider,
      (AsyncValue<List<CardPaymentModel>>? _,
          AsyncValue<List<CardPaymentModel>> next) {
        final List<CardPaymentModel>? cards = next.valueOrNull;
        if (cards == null) return;
        state = AsyncValue<CardPaymentModel?>.data(
          cards.isEmpty ? null : cards.first,
        );
        _seedSub?.close();
        _seedSub = null;
      },
    );
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
        // one-shot seed is already closed, so this refetch does not write back
        // into this provider.
        _ref.read(getMyCardsProvider.notifier).getMyCards();
        return null;
      },
    );
  }
}
