import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/welcome/data/repo/welcome_repo.dart';

/// Provider for the "continue as guest" button on the onboarding screen.
///
/// `data(null)` = idle, `loading` = request in flight, `data(token)` =
/// success (navigate), `error` = show the message. Triggered via
/// `ref.read(generateGuestTokenProvider.notifier).generateGuestToken()`.
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

  /// Calls the API to issue a new guest token and saves it to the cache.
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
