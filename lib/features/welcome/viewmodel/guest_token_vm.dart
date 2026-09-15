import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/welcome/data/repo/welcome_repo.dart';






final generateGuestTokenProvider = StateNotifierProvider.autoDispose<
    GuestTokenViewModel, AsyncValue<String?>>(
  (Ref ref) => GuestTokenViewModel(),
);

class GuestTokenViewModel extends StateNotifier<AsyncValue<String?>> {
  GuestTokenViewModel() : super(const AsyncValue.data(null));

  final WelcomeRepo _repo = WelcomeRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }


  Future<void> generateGuestToken() async {
    state = const AsyncValue.loading();

    final result = await _repo.generateGuestToken();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) => AsyncValue.error(failure.message, StackTrace.current),
      (String guestToken) => AsyncValue.data(guestToken),
    );
  }
}
