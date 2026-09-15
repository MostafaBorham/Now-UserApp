import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/wallet/data/repo/wallet_repo.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';


















final deletePaymentCardProvider = StateNotifierProvider.autoDispose<
    DeletePaymentCardViewModel, AsyncValue<void>>(
  (Ref ref) => DeletePaymentCardViewModel(ref),
);

class DeletePaymentCardViewModel extends StateNotifier<AsyncValue<void>> {
  DeletePaymentCardViewModel(this._ref)
      : super(const AsyncValue<void>.data(null));

  final Ref _ref;
  final WalletRepo _repo = WalletRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<String?> deletePaymentCard(int id) async {
    state = const AsyncValue<void>.loading();

    final Either<Failure, void> result = await _repo.deletePaymentCard(id);

    if (!mounted) return null;

    return result.fold(
      (Failure failure) {
        state = AsyncValue<void>.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (_) {
        state = const AsyncValue<void>.data(null);


        _ref.read(getMyCardsProvider.notifier).getMyCards();
        return null;
      },
    );
  }
}
