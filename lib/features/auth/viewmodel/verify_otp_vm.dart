import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/auth/data/models/user_model.dart';
import 'package:nowdelivery_user_app/features/auth/data/repo/auth_repo.dart';

/// Provider for the "continue" button on the OTP verification screen.
///
/// `data(null)` = idle, `loading` = request in flight, `data(user)` =
/// logged in successfully (navigate), `error` = show the message. Triggered
/// via `ref.read(verifyOtpProvider.notifier).verifyOtp(phone: ..., code: ...)`.
final verifyOtpProvider = StateNotifierProvider.autoDispose<
    VerifyOtpViewModel, AsyncValue<UserModel?>>(
  (Ref ref) => VerifyOtpViewModel(),
);

class VerifyOtpViewModel extends StateNotifier<AsyncValue<UserModel?>> {
  VerifyOtpViewModel() : super(const AsyncValue.data(null));

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

    state = result.fold(
      (Failure failure) => AsyncValue.error(failure.message, StackTrace.current),
      (UserModel user) => AsyncValue.data(user),
    );
  }
}
