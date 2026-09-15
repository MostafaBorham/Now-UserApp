import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/repo/wallet_repo.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';



















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



        _ref.read(getMyCardsProvider.notifier).getMyCards();
        return null;
      },
    );
  }
}
