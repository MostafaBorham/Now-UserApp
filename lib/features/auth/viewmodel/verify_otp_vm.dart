import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/auth/data/models/user_model.dart';
import 'package:nowdelivery_user_app/features/auth/data/repo/auth_repo.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';






final verifyOtpProvider = StateNotifierProvider.autoDispose<
    VerifyOtpViewModel, AsyncValue<UserModel?>>(
  (Ref ref) => VerifyOtpViewModel(ref),
);

class VerifyOtpViewModel extends StateNotifier<AsyncValue<UserModel?>> {
  VerifyOtpViewModel(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;
  final AuthRepo _repo = AuthRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }




  Future<void> verifyOtp({required String phone, required String code}) async {
    state = const AsyncValue.loading();

    final result = await _repo.verifyOtp(phone: phone, code: code);

    if (!mounted) return;

    await result.fold(
      (Failure failure) async {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (UserModel user) async {









        await _ref
            .read(authSessionProvider.notifier)
            .resolveSession(awaitDependencies: true);

        if (!mounted) return;

        state = AsyncValue.data(user);
      },
    );
  }
}
