import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/welcome/data/repo/welcome_repo.dart';

/// Single task: issue a guest token and cache it (done inside the repo).
///
/// Unlike list viewmodels, this one does NOT fetch on first watch — it is
/// triggered by the "continue as guest" button via
/// `ref.read(getGuestTokenProvider.notifier).getGuestToken()`. The state is
/// `AsyncValue<String?>`: `data(null)` = idle, `loading` = request in
/// flight, `data(token)` = success (navigate), `error` = show the message.
final getGuestTokenProvider = StateNotifierProvider.autoDispose<
    GetGuestTokenViewModel, AsyncValue<String?>>(
  (Ref ref) => GetGuestTokenViewModel(const AsyncValue.data(null)),
);

class GetGuestTokenViewModel extends StateNotifier<AsyncValue<String?>> {
  GetGuestTokenViewModel(super.initialState);

  final WelcomeRepo _repo = WelcomeRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getGuestToken() async {
    print('guest loading');
    state = const AsyncValue.loading();

    final result = await _repo.getGuestToken();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) {
        print('guest fail');
        return AsyncValue.error(failure.message, StackTrace.current);
      },
      (String guestToken) {
        print('guest success');
        return AsyncValue.data(guestToken);
      },
    );
  }
}
