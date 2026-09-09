import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/wallet/data/repo/wallet_repo.dart';

/// One-shot action: delete a saved payment card.
///
/// Nothing is requested when first watched — deleting is a user action — so the
/// notifier starts idle (`AsyncValue.data(null)`) and a caller triggers it with
/// `ref.read(deletePaymentCardProvider.notifier).deletePaymentCard(id)`,
/// watching the loading slice to drive a button spinner.
///
/// On success `state` becomes `data(null)` and `null` is returned; on failure
/// `state` becomes an error and the message is also returned so the caller can
/// surface it in a snackbar.
final deletePaymentCardProvider = StateNotifierProvider.autoDispose<
    DeletePaymentCardViewModel, AsyncValue<void>>(
  (Ref ref) => DeletePaymentCardViewModel(),
);

class DeletePaymentCardViewModel extends StateNotifier<AsyncValue<void>> {
  DeletePaymentCardViewModel() : super(const AsyncValue<void>.data(null));

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
        return null;
      },
    );
  }
}
