import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/auth/data/models/user_model.dart';
import 'package:nowdelivery_user_app/features/auth/data/repo/auth_repo.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';

/// Provider for the "continue" button on the OTP verification screen.
///
/// `data(null)` = idle, `loading` = request in flight, `data(user)` =
/// logged in successfully (navigate), `error` = show the message. Triggered
/// via `ref.read(verifyOtpProvider.notifier).verifyOtp(phone: ..., code: ...)`.
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

  /// Calls the API to verify the OTP [code] sent to [phone]. On success the
  /// repo has already replaced the cached guest token with the auth token
  /// (`isGuest: false`); the state carries the logged-in user.
  Future<void> verifyOtp({required String phone, required String code}) async {
    state = const AsyncValue.loading();

    final result = await _repo.verifyOtp(phone: phone, code: code);

    if (!mounted) return;

    await result.fold(
      (Failure failure) async {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (UserModel user) async {
        // The auth token now replaces the guest token, so the session flipped
        // to a logged-in user. Push it through the orchestrator before exposing
        // the user: it refreshes the session type (so anything watching it sees
        // the new value) and, off the guest→user change, fires every
        // session-dependent request (getMyOrders, …) on our behalf.
        //
        // `awaitDependencies: true`: hold the OTP screen (the button stays in
        // its loading state) until every dependency has settled, so the user is
        // never dropped into the app before its data is ready.
        await _ref
            .read(authSessionProvider.notifier)
            .resolveSession(awaitDependencies: true);

        if (!mounted) return;

        state = AsyncValue.data(user);
      },
    );
  }
}
