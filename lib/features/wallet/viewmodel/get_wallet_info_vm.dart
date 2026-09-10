import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/repo/wallet_repo.dart';

/// Single task: fetch the wallet balance, currency and top-up limits.
///
/// `autoDispose`: the wallet screen is the only consumer, so the state is torn
/// down when it leaves. The fetch fires as soon as the provider is first
/// read/watched — screens only `ref.watch(getWalletInfoProvider)` and render
/// the [AsyncValue]. Retry with
/// `ref.read(getWalletInfoProvider.notifier).getWalletInfo()`.
final getWalletInfoProvider = StateNotifierProvider.autoDispose<
    GetWalletInfoViewModel, AsyncValue<WalletModel>>(
  (Ref ref) => GetWalletInfoViewModel()..getWalletInfo(),
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
