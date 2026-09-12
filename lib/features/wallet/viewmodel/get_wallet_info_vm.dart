import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/repo/wallet_repo.dart';

/// Single task: hold the wallet balance, currency and top-up limits, shared
/// across the app.
///
/// Deliberately **not** `autoDispose` and it does **not** fetch on creation: it
/// is the session orchestrator that fires [getWalletInfo] once when a user
/// session resolves (see `AuthSessionViewModel`) and invalidates it on logout,
/// exactly like the other user dependencies. Screens only
/// `ref.watch(getWalletInfoProvider)` and render the [AsyncValue]; retry with
/// `ref.read(getWalletInfoProvider.notifier).getWalletInfo()`.
final getWalletInfoProvider = StateNotifierProvider<GetWalletInfoViewModel,
    AsyncValue<WalletModel>>(
  (Ref ref) => GetWalletInfoViewModel(),
);

class GetWalletInfoViewModel extends StateNotifier<AsyncValue<WalletModel>> {
  GetWalletInfoViewModel() : super(const AsyncValue.loading());

  final WalletRepo _repo = WalletRepo();

  Future<void> getWalletInfo() async {
    state = const AsyncValue.loading();

    final result = await _repo.getWalletInfo();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (WalletModel wallet) => AsyncValue.data(wallet),
    );
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
