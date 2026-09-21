import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/database/cache_purger.dart';
import 'package:nowdelivery_user_app/core/enums/session_types.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';
import 'package:nowdelivery_user_app/features/auth/data/repo/auth_repo.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/selected_store_coupons_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';
import 'package:nowdelivery_user_app/features/promotion/viewmodel/get_coupons_vm.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_featured_stores_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/default_payment_card_provider.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_info_vm.dart';

/// Every kept-alive provider that belongs to the signed-in user.
///
/// Adding a provider here is what makes it die when the session changes: the
/// list is iterated by [AuthSessionViewModel._disposeUserDependencies], so a
/// provider's classification and its actual behaviour cannot drift apart.
///
/// Only **user**-scoped providers belong here. App-wide content and device
/// state (the locale, the catalogue, where the phone is) outlive the session on
/// purpose, and `test/core/session/session_scoped_providers_test.dart` keeps a
/// matching exemption list — it fails when a new non-`autoDispose` provider
/// appears in `lib/` and is in neither, which is exactly how the cart came to
/// survive logout unnoticed.
final List<ProviderOrFamily> sessionScopedProviders = <ProviderOrFamily>[
  getMyOrdersProvider,
  getMyAddressesProvider,
  defaultAddressProvider,
  getCouponsProvider,
  getProfileProvider,
  getMyCardsProvider,
  getWalletInfoProvider,
  // Holds its own state seeded once from the cards list, so it must be dropped
  // explicitly — otherwise the next user would inherit this user's default.
  defaultPaymentCardProvider,
  // Kept alive so the cart survives leaving the cart screen — which also made
  // it survive logout and served the previous user's basket to the next
  // account, since the cart screen only fetches when the provider is empty.
  getCartProvider,
  // The draft order group: the previous user's items, delivery address and
  // totals.
  checkoutProvider,
  // Coupons the previous user picked on a store screen, waiting to be applied
  // to their checkout.
  selectedStoreCouponsProvider,
  // The feed and the "Best brands" carousel are not pure catalogue: every
  // product and store in their payloads carries `cart_quantity` and
  // `is_favourite` for the user who fetched it.
  getHomeSectionsProvider,
  getFeaturedStoresProvider,
];

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
  /// By default returns as soon as the session type is settled and any load has
  /// been *kicked off* — it does not wait for the dependencies to finish, so the
  /// splash (which watches [AuthSessionState.dependenciesStatus] instead) is
  /// never blocked on the call itself.
  ///
  /// Pass [awaitDependencies] `true` to instead await the whole dependency load
  /// before returning — the login flow uses this so it does not leave the OTP
  /// screen until every session-dependent request has settled. For a guest (no
  /// dependencies) it returns immediately either way.
  ///
  /// This is also the forced-logout entry point: once the tokens are gone the
  /// session reads back as a guest, so clearing them and calling this is all a
  /// caller outside the provider graph needs to do (see
  /// `TokenRefreshInterceptor.onSessionExpired`).
  Future<void> resolveSession({bool awaitDependencies = false}) async {
    final result = await _repo.getSessionType();

    if (!mounted) return;

    final SessionType next = result.fold(
      (Failure _) => SessionType.guest,
      (SessionType t) => t,
    );

    // Drop the outgoing session's data before the incoming one is applied —
    // whichever direction it went. Doing this only on user→guest is what let a
    // guest's cart carry into the account they logged into.
    //
    // Cold boot is exempt: there is no previous session to clear, and wiping
    // here would throw away the very caches the offline-first repos are about
    // to read.
    final bool isBoot = state.dependenciesStatus == AppDependenciesStatus.idle;

    if (!isBoot && state.sessionType != next) {
      await _disposeUserDependencies();
      if (!mounted) return;
    }

    final Future<void> load = _apply(next);

    if (awaitDependencies) await load;
  }

  /// Applies [next] and runs the matching side effect:
  ///
  /// * [SessionType.user]  : mark the dependencies [AppDependenciesStatus.loading]
  ///   and kick off [_loadUserDependencies], which flips to
  ///   [AppDependenciesStatus.ready] once every request settles.
  /// * [SessionType.guest] : settle straight to [AppDependenciesStatus.ready] —
  ///   a guest has nothing to wait for.
  ///
  /// Clearing the outgoing session belongs to [resolveSession], which has
  /// already run by the time this is called.
  ///
  /// Deliberately **not** `async`: it *returns* the load future instead of
  /// awaiting it, so [resolveSession] can choose. An `async` body would await
  /// the future it returns, and the splash — which only wants the load kicked
  /// off — would start blocking on every dependency request.
  Future<void> _apply(SessionType next) {
    switch (next) {
      case SessionType.user:
        state = state.copyWith(
          sessionType: next,
          dependenciesStatus: AppDependenciesStatus.loading,
        );
        return _loadUserDependencies();
      case SessionType.guest:
        state = state.copyWith(
          sessionType: next,
          dependenciesStatus: AppDependenciesStatus.ready,
        );
        return Future<void>.value();
    }
  }

  Future<void> _loadUserDependencies() async {
    await Future.wait(<Future<void>>[
      _ref.read(getMyOrdersProvider.notifier).getOrders(),
      _ref.read(getMyAddressesProvider.notifier).loadFirstPage(),
      _ref.read(defaultAddressProvider.notifier).getDefaultAddress(),
      _ref.read(getCouponsProvider.notifier).getCoupons(),
      _ref.read(getProfileProvider.notifier).getProfile(),
      // Saved cards are no longer fetched at boot: they are loaded fresh when
      // the wallet's "My Cards" / "Add Balance" buttons are tapped (see
      // WalletScreen). getMyCardsProvider stays session-scoped below so the
      // list still dies on logout.
      _ref.read(getWalletInfoProvider.notifier).getWalletInfo(),
      // Fetched here rather than left to the cart screen: on guest→login the
      // main shell (and with it CartView) can stay mounted, so its
      // "fetch only when empty" guard never runs again and the freshly
      // invalidated cart would sit empty until a manual pull-to-refresh.
      _ref.read(getCartProvider.notifier).getCart(),
    ]);

    if (!mounted) return;

    // A failed background coupons load must not stick to this kept-alive
    // provider: drop it from the outside so the next open (DiscountCodeScreen)
    // gets a fresh VM in the `loading` state and fetches again.
    if (_ref.read(getCouponsProvider).hasError) {
      _ref.invalidate(getCouponsProvider);
    }

    state = state.copyWith(dependenciesStatus: AppDependenciesStatus.ready);
  }
  /// Drops everything the previous user left behind: first the in-memory
  /// providers, then their Hive mirrors on disk.
  ///
  /// The order matters. Invalidating a provider disposes its view model, which
  /// cancels that feature's in-flight requests — so nothing can land after the
  /// purge and write the old user's payload straight back into a box we just
  /// cleared.
  Future<void> _disposeUserDependencies() async {
    for (final ProviderOrFamily provider in sessionScopedProviders) {
      _ref.invalidate(provider);
    }

    // Providers are memory only. Without this the cached profile, orders, cards
    // and wallet stay on disk and are served to the next user as the offline
    // fallback — see [CachePurger].
    await CachePurger.purgeUserData();
  }
}
