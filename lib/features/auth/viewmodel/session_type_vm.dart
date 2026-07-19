import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/enums/session_types.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/auth/data/repo/auth_repo.dart';

/// Provider exposing the [SessionType] of the cached session, resolved on
/// first watch. Screens use it to adapt to guest vs. logged-in state (e.g.
/// the settings screen only shows the "Log Out" button for a user).
final sessionTypeProvider =
    StateNotifierProvider.autoDispose<SessionTypeViewModel, SessionType>(
  (Ref ref) => SessionTypeViewModel()..getSessionType(),
);

class SessionTypeViewModel extends StateNotifier<SessionType> {
  /// Starts as [SessionType.guest] — the safe default until the cache read
  /// resolves (and the fallback when it fails).
  SessionTypeViewModel() : super(SessionType.guest);

  final AuthRepo _repo = AuthRepo();

  /// Resolves the session type from the cache through the repo. A failure
  /// collapses to [SessionType.guest] so callers never see an error state.
  Future<void> getSessionType() async {
    final result = await _repo.getSessionType();

    if (!mounted) return;

    state = result.fold(
      (Failure _) => SessionType.guest,
      (SessionType type) => type,
    );
  }
}
