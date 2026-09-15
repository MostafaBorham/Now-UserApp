import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/repo/wallet_repo.dart';











final getMyCardsProvider = StateNotifierProvider<GetMyCardsViewModel,
    AsyncValue<List<CardPaymentModel>>>(
  (Ref ref) => GetMyCardsViewModel(),
);

class GetMyCardsViewModel
    extends StateNotifier<AsyncValue<List<CardPaymentModel>>> {
  GetMyCardsViewModel() : super(const AsyncValue.loading());

  final WalletRepo _repo = WalletRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getMyCards() async {






    state = const AsyncValue.loading();

    final result = await _repo.getMyCards();

    if (!mounted) return;

    result.fold(
      (Failure failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (List<CardPaymentModel> cards) => state = AsyncValue.data(cards),
    );
  }
}
