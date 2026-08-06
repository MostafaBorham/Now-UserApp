import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/enums/session_types.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/auth/data/repo/auth_repo.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';

/// Where the app's session-dependent dependencies stand.
///
/// [idle] — nothing has been resolved yet (the VM was created but no one has
/// called [AuthSessionViewModel.resolveSession] — this is the state until the
/// splash triggers the first resolve). [loading] — a logged-in user's
/// dependencies are being fetched. [ready] — resolution finished and there is
/// nothing left to wait for (a user's dependencies all loaded, or a guest has
/// none). The splash watches this to know when it may leave.
enum AppDependenciesStatus { idle, loading, ready }

/// The exposed state of the auth session: the current [SessionType] and how far
/// its session-dependent dependencies have got ([AppDependenciesStatus]).
class AuthSessionState {
  const AuthSessionState({
    required this.sessionType,
    required this.dependenciesStatus,
  });

  /// The starting point: a guest with nothing resolved yet. No cache has been
  /// read and no dependency fired until [AuthSessionViewModel.resolveSession]
  /// is first called.
  const AuthSessionState.initial()
      : sessionType = SessionType.guest,
        dependenciesStatus = AppDependenciesStatus.idle;

  final SessionType sessionType;
  final AppDependenciesStatus dependenciesStatus;

  AuthSessionState copyWith({
    SessionType? sessionType,
    AppDependenciesStatus? dependenciesStatus,
  }) {
    return AuthSessionState(
      sessionType: sessionType ?? this.sessionType,
      dependenciesStatus: dependenciesStatus ?? this.dependenciesStatus,
    );
  }
}

/// The single, always-alive source of truth for the session, and the one
/// orchestrator of every session-dependent dependency in the app.
///
/// Deliberately **not** `autoDispose`, and it does **not** resolve on creation:
/// the instance is brought online at the app root ([resolveSession] is *not*
/// called there), and stays idle until someone needs it. The first need is the
/// splash — once its logo animation ends it calls [resolveSession], which reads
/// the cached session and, for a logged-in user, fires the dependencies while
/// the splash shows its loader; the splash then leaves as soon as
/// [AppDependenciesStatus.ready] lands.
///
/// The same [resolveSession] is replayed after any later login/logout, so the
/// orchestrator reacts wherever the session changes — not only on the splash.
///
/// Screens read [AuthSessionState.sessionType] to adapt to guest vs. user; the
/// orchestration is a side effect they never see.
final authSessionProvider =
    StateNotifierProvider<AuthSessionViewModel, AuthSessionState>(
  (Ref ref) => AuthSessionViewModel(ref),
);

class AuthSessionViewModel extends StateNotifier<AuthSessionState> {
  AuthSessionViewModel(this._ref) : super(const AuthSessionState.initial());

  final Ref _ref;
  final AuthRepo _repo = AuthRepo();

  /// Reads the cached session through the repo and applies it. This is the
  /// on-demand entry point — called first by the splash when its animation
  /// ends, and again after any login/logout so the orchestrator re-evaluates. A
  /// cache read failure collapses to [SessionType.guest] so callers never see
  /// an error state.
  ///
  /// Returns as soon as the session type is settled and any load has been
  /// *kicked off* — it does not wait for the dependencies to finish, so a login
  /// is never blocked on them. Progress is published through
  /// [AuthSessionState.dependenciesStatus] for whoever is watching (the splash).
  Future<void> resolveSession() async {
    final result = await _repo.getSessionType();

    if (!mounted) return;

    _apply(result.fold((Failure _) => SessionType.guest, (SessionType t) => t));
  }

  /// Applies [next] and runs the matching side effect:
  ///
  /// * [SessionType.user]  : mark the dependencies [AppDependenciesStatus.loading]
  ///   and kick off [_loadUserDependencies], which flips to
  ///   [AppDependenciesStatus.ready] once every request settles.
  /// * [SessionType.guest] : drop the previous user's data (only if we *were* a
  ///   user) and settle straight to [AppDependenciesStatus.ready] — a guest has
  ///   nothing to wait for.
  void _apply(SessionType next) {
    final SessionType previous = state.sessionType;

    switch (next) {
      case SessionType.user:
        state = state.copyWith(
          sessionType: next,
          dependenciesStatus: AppDependenciesStatus.loading,
        );
        _loadUserDependencies();
      case SessionType.guest:
        if (previous == SessionType.user) {
          _disposeUserDependencies();
        }
        state = state.copyWith(
          sessionType: next,
          dependenciesStatus: AppDependenciesStatus.ready,
        );
    }
  }

  Future<void> _loadUserDependencies() async {
    await Future.wait(<Future<void>>[
      _ref.read(getMyOrdersProvider.notifier).getOrders(),
    ]);

    if (!mounted) return;

    state = state.copyWith(dependenciesStatus: AppDependenciesStatus.ready);
  }
  void _disposeUserDependencies() {
    _ref.invalidate(getMyOrdersProvider);
  }
}
