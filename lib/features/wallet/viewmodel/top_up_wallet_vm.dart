import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_top_up_attempt.dart';
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
/// The top-up is non-idempotent, so every submit runs against a persisted
/// [WalletTopUpAttempt]: one key per (amount, payment method), reused across
/// retries of that same submit and dropped once the server confirms it. The
/// record lives on disk rather than in this view model because cancelling the
/// request, closing the sheet, or the process being killed does **not** cancel
/// the attempt server-side — losing the key would turn the customer's retry into
/// a second charge.
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

    // Resolved and persisted before the request goes out: a retry of this same
    // submit resends the original key and the server replays its first result,
    // rather than recording a second top-up.
    final WalletTopUpAttempt attempt = await _repo.resolveTopUpAttempt(
      amountHalalas: amountHalalas,
      paymentMethodId: paymentMethodId,
    );

    final Either<Failure, WalletModel> result = await _repo.topUpWallet(
      amountHalalas: attempt.amountHalalas,
      paymentMethodId: attempt.paymentMethodId,
      idempotencyKey: attempt.idempotencyKey,
    );

    final (WalletModel? wallet, Failure? failure) = result.fold(
      (Failure f) => (null, f),
      (WalletModel w) => (w, null),
    );

    if (wallet == null) {
      // The attempt is deliberately left on disk. The outcome of a failed or
      // timed-out submit isn't knowable from here, so a retry has to be able to
      // resend the same key — minting a new one would defeat the server's
      // dedupe and charge again.
      final String message =
          failure?.message ?? LangKeys.serverConnectionFailedKey;
      if (!mounted) return null;
      state = AsyncValue<void>.error(message, StackTrace.current);
      return message;
    }

    // Confirmed by the server: this attempt is spent, so a later deliberate
    // top-up mints a fresh key instead of replaying this one.
    await _repo.clearTopUpAttempt();

    if (!mounted) return null;

    // Publish the server's fresh wallet so the balance updates immediately.
    _ref.read(getWalletInfoProvider.notifier).setWallet(wallet);
    state = const AsyncValue<void>.data(null);
    return null;
  }
}
