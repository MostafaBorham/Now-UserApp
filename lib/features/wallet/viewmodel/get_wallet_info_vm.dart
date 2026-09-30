import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/repo/wallet_repo.dart';

/// Single task: hold the wallet balance, currency and top-up limits, shared
/// across the app.
///
/// Deliberately **not** `autoDispose` and it does **not** fetch on creation:
/// the screens that show the balance ask for a fresh copy each time they open
/// (checkout and the wallet screen), because a refund, a credit or an order
/// paid from the wallet changes it behind the app's back. It is invalidated on
/// logout via `sessionScopedProviders`. Screens `ref.watch` it and render the
/// [AsyncValue]; retry with
/// `ref.read(getWalletInfoProvider.notifier).getWalletInfo()`.
///
/// A refresh keeps the last balance while it loads or fails. A balance served
/// from the offline cache arrives as an error carrying that balance as its
/// value: `hasError` then means "not current", and `valueOrNull` is still the
/// last known amount.
final getWalletInfoProvider = StateNotifierProvider<GetWalletInfoViewModel,
    AsyncValue<WalletModel>>(
  (Ref ref) => GetWalletInfoViewModel(),
);

class GetWalletInfoViewModel extends StateNotifier<AsyncValue<WalletModel>> {
  GetWalletInfoViewModel() : super(const AsyncValue.loading());

  final WalletRepo _repo = WalletRepo();

  Future<void> getWalletInfo() async {
    state = const AsyncValue<WalletModel>.loading().copyWithPrevious(state);

    final result = await _repo.getWalletInfo();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) => AsyncValue<WalletModel>.error(
        failure.message,
        StackTrace.current,
      ).copyWithPrevious(state),
      (({WalletModel wallet, bool isFromCache}) info) => info.isFromCache
          ? AsyncValue<WalletModel>.error(
              LangKeys.walletBalanceNotUpdatedKey,
              StackTrace.current,
            ).copyWithPrevious(AsyncValue.data(info.wallet))
          : AsyncValue.data(info.wallet),
    );
  }

  /// Publishes a [wallet] already resolved elsewhere (e.g. the fresh copy a
  /// top-up returns) so the shared state reflects the new balance without a
  /// round-trip.
  void setWallet(WalletModel wallet) => state = AsyncValue.data(wallet);

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
