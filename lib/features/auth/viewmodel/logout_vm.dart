import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/auth/data/repo/auth_repo.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';






final logoutProvider =
    StateNotifierProvider.autoDispose<LogoutViewModel, AsyncValue<Unit?>>(
  (Ref ref) => LogoutViewModel(ref),
);

class LogoutViewModel extends StateNotifier<AsyncValue<Unit?>> {
  LogoutViewModel(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;
  final AuthRepo _repo = AuthRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }






  Future<void> logout() async {
    state = const AsyncValue.loading();

    final result = await _repo.logout();

    if (!mounted) return;

    await result.fold(
      (Failure failure) async {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (Unit _) async {
        await _ref.read(authSessionProvider.notifier).resolveSession();
        if (!mounted) return;
        state = const AsyncValue.data(unit);
      },
    );
  }
}
