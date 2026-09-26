import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/auth/data/repo/auth_repo.dart';

/// A code is on its way to [phone]; the next one may be asked for in
/// [retryAfterSeconds]. Also the OTP route's `extra`.
typedef OtpSent = ({String phone, int retryAfterSeconds});

/// Provider for the "continue" button on the phone verification screen.
///
/// `data(null)` = idle, `loading` = request in flight, `data(sent)` =
/// a code is on its way (navigate to the OTP screen), `error` = show the
/// message. Triggered via
/// `ref.read(requestOtpProvider.notifier).requestOtp(phone)`.
final requestOtpProvider =
    StateNotifierProvider.autoDispose<
      RequestOtpViewModel,
      AsyncValue<OtpSent?>
    >((Ref ref) => RequestOtpViewModel());

class RequestOtpViewModel extends StateNotifier<AsyncValue<OtpSent?>> {
  RequestOtpViewModel() : super(const AsyncValue.data(null));

  final AuthRepo _repo = AuthRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  /// Calls the API to send an OTP to [phone].
  Future<void> requestOtp(String phone) async {
    state = const AsyncValue.loading();

    final result = await _repo.requestOtp(phone: phone);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (int retryAfterSeconds) =>
          AsyncValue.data((phone: phone, retryAfterSeconds: retryAfterSeconds)),
    );
  }
}
