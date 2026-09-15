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

  Future<String?> topUpWallet({required int amount}) async {



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
      (WalletModel wallet) {

        _idempotencyKey.markConsumed();

        _ref.read(getWalletInfoProvider.notifier).setWallet(wallet);
        state = const AsyncValue<void>.data(null);
        return null;
      },
    );
  }
}
