import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/utils/idempotency_key.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/repo/wallet_repo.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/default_payment_card_provider.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_info_vm.dart';

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
  (Ref ref) => TopUpWalletViewModel(ref),
);

class TopUpWalletViewModel extends StateNotifier<AsyncValue<void>> {
  TopUpWalletViewModel(this._ref) : super(const AsyncValue<void>.data(null));

  final Ref _ref;
  final WalletRepo _repo = WalletRepo();
  final IdempotencyKey _idempotencyKey = IdempotencyKey();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<String?> topUpWallet({required int amountHalalas}) async {
    // The payment method is always the customer's current default card. If none
    // is selected there is nothing to charge, so fail fast with a message before
    // hitting the repo.
    final CardPaymentModel? defaultCard =
        _ref.read(defaultPaymentCardProvider).valueOrNull;
    final int? paymentMethodId = defaultCard?.id;
    if (paymentMethodId == null) {
      state = AsyncValue<void>.error(
        LangKeys.selectPaymentMethodFirstKey,
        StackTrace.current,
      );
      return LangKeys.selectPaymentMethodFirstKey;
    }

    state = const AsyncValue<void>.loading();

    final Either<Failure, WalletModel> result = await _repo.topUpWallet(
      amountHalalas: amountHalalas,
      paymentMethodId: paymentMethodId,
      idempotencyKey:
          _idempotencyKey.forRequest('$amountHalalas|$paymentMethodId'),
    );

    if (!mounted) return null;

    return result.fold(
      (Failure failure) {
        state = AsyncValue<void>.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (WalletModel wallet) {
        // A genuine repeat top-up must not replay this one's result.
        _idempotencyKey.markConsumed();
        // Publish the server's fresh wallet so the balance updates immediately.
        _ref.read(getWalletInfoProvider.notifier).setWallet(wallet);
        state = const AsyncValue<void>.data(null);
        return null;
      },
    );
  }
}
