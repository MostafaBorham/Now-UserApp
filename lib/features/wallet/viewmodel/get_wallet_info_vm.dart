import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/repo/wallet_repo.dart';










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




  void setWallet(WalletModel wallet) => state = AsyncValue.data(wallet);

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
