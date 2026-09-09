import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/utils/idempotency_key.dart';
import 'package:nowdelivery_user_app/features/wallet/data/repo/wallet_repo.dart';

/// One-shot action: top the wallet up with an amount via a payment method.
///
/// Nothing is requested when first watched — topping up is a user action — so
/// the notifier starts idle (`AsyncValue.data(null)`) and a caller triggers it
/// with `ref.read(topUpWalletProvider.notifier).topUpWallet(...)`, watching the
/// loading slice to drive a button spinner.
///
/// The top-up is non-idempotent, so this view model owns the [IdempotencyKey]:
/// it mints one key per (amount, payment method) submit, reuses it across
/// retries of that same submit, and rotates it once the top-up succeeds — the
/// server dedupes lost-response retries without ever double-charging.
///
/// On success `state` becomes `data(null)` and `null` is returned; on failure
/// `state` becomes an error and the message is also returned so the caller can
/// surface it in a snackbar.
final topUpWalletProvider =
    StateNotifierProvider.autoDispose<TopUpWalletViewModel, AsyncValue<void>>(
  (Ref ref) => TopUpWalletViewModel(),
);

class TopUpWalletViewModel extends StateNotifier<AsyncValue<void>> {
  TopUpWalletViewModel() : super(const AsyncValue<void>.data(null));

  final WalletRepo _repo = WalletRepo();
  final IdempotencyKey _idempotencyKey = IdempotencyKey();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<String?> topUpWallet({
    required int amount,
    required int paymentMethodId,
  }) async {
    state = const AsyncValue<void>.loading();

    final Either<Failure, void> result = await _repo.topUpWallet(
      amount: amount,
      paymentMethodId: paymentMethodId,
      idempotencyKey: _idempotencyKey.forRequest('$amount|$paymentMethodId'),
    );

    if (!mounted) return null;

    return result.fold(
      (Failure failure) {
        state = AsyncValue<void>.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (_) {
        // A genuine repeat top-up must not replay this one's result.
        _idempotencyKey.markConsumed();
        state = const AsyncValue<void>.data(null);
        return null;
      },
    );
  }
}
