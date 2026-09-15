import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/auth/data/repo/auth_repo.dart';







final requestOtpProvider = StateNotifierProvider.autoDispose<
    RequestOtpViewModel, AsyncValue<String?>>(
  (Ref ref) => RequestOtpViewModel(),
);

class RequestOtpViewModel extends StateNotifier<AsyncValue<String?>> {
  RequestOtpViewModel() : super(const AsyncValue.data(null));

  final AuthRepo _repo = AuthRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }


  Future<void> requestOtp(String phone) async {
    state = const AsyncValue.loading();

    final result = await _repo.requestOtp(phone: phone);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) => AsyncValue.error(failure.message, StackTrace.current),
      (String sentToPhone) => AsyncValue.data(sentToPhone),
    );
  }
}
