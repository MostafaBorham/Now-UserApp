import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/auth/data/repo/auth_repo.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';

/// Provider for the "Log Out" button on the settings screen.
///
/// `data(null)` = idle, `loading` = request in flight, `data(unit)` = logged
/// out successfully (navigate to onboarding), `error` = show the message.
/// Triggered via `ref.read(logoutProvider.notifier).logout()`.
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

  /// Calls the API to log the user out. On success the repo has already
  /// cleared the cached session, so we push the new session through the
  /// orchestrator: it flips to guest and, off the user→guest change, invalidates
  /// every session-dependent provider (getMyOrders, …). The state carries
  /// `unit`.
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
