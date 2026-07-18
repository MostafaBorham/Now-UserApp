import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/auth/data/repo/auth_repo.dart';

/// Provider for the "Log Out" button on the settings screen.
///
/// `data(null)` = idle, `loading` = request in flight, `data(unit)` = logged
/// out successfully (navigate to onboarding), `error` = show the message.
/// Triggered via `ref.read(logoutProvider.notifier).logout()`.
final logoutProvider =
    StateNotifierProvider.autoDispose<LogoutViewModel, AsyncValue<Unit?>>(
  (Ref ref) => LogoutViewModel(),
);

class LogoutViewModel extends StateNotifier<AsyncValue<Unit?>> {
  LogoutViewModel() : super(const AsyncValue.data(null));

  final AuthRepo _repo = AuthRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  /// Calls the API to log the user out. On success the repo has already
  /// cleared the cached session; the state carries `unit`.
  Future<void> logout() async {
    state = const AsyncValue.loading();

    final result = await _repo.logout();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) => AsyncValue.error(failure.message, StackTrace.current),
      (Unit _) => const AsyncValue.data(unit),
    );
  }
}
