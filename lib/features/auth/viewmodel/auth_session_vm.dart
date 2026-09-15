import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/database/cache_purger.dart';
import 'package:nowdelivery_user_app/core/enums/session_types.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';
import 'package:nowdelivery_user_app/features/auth/data/repo/auth_repo.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';
import 'package:nowdelivery_user_app/features/promotion/viewmodel/get_coupons_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/default_payment_card_provider.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_my_cards_vm.dart';
import 'package:nowdelivery_user_app/features/wallet/viewmodel/get_wallet_info_vm.dart';









enum AppDependenciesStatus { idle, loading, ready }



class AuthSessionState {
  const AuthSessionState({
    required this.sessionType,
    required this.dependenciesStatus,
  });




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

















final authSessionProvider =
    StateNotifierProvider<AuthSessionViewModel, AuthSessionState>(
  (Ref ref) => AuthSessionViewModel(ref),
);

class AuthSessionViewModel extends StateNotifier<AuthSessionState> {
  AuthSessionViewModel(this._ref) : super(const AuthSessionState.initial());

  final Ref _ref;
  final AuthRepo _repo = AuthRepo();
















  Future<void> resolveSession({bool awaitDependencies = false}) async {
    final result = await _repo.getSessionType();

    if (!mounted) return;

    final Future<void> load = _apply(
      result.fold((Failure _) => SessionType.guest, (SessionType t) => t),
    );

    if (awaitDependencies) await load;
  }












  Future<void> _apply(SessionType next) {
    final SessionType previous = state.sessionType;

    switch (next) {
      case SessionType.user:
        state = state.copyWith(
          sessionType: next,
          dependenciesStatus: AppDependenciesStatus.loading,
        );
        return _loadUserDependencies();
      case SessionType.guest:
        final Future<void> disposal = previous == SessionType.user
            ? _disposeUserDependencies()
            : Future<void>.value();
        state = state.copyWith(
          sessionType: next,
          dependenciesStatus: AppDependenciesStatus.ready,
        );
        return disposal;
    }
  }

  Future<void> _loadUserDependencies() async {
    await Future.wait(<Future<void>>[
      _ref.read(getMyOrdersProvider.notifier).getOrders(),
      _ref.read(getMyAddressesProvider.notifier).loadFirstPage(),
      _ref.read(defaultAddressProvider.notifier).getDefaultAddress(),
      _ref.read(getCouponsProvider.notifier).getCoupons(),
      _ref.read(getProfileProvider.notifier).getProfile(),
      _ref.read(getMyCardsProvider.notifier).getMyCards(),
      _ref.read(getWalletInfoProvider.notifier).getWalletInfo(),
    ]);

    if (!mounted) return;




    if (_ref.read(getCouponsProvider).hasError) {
      _ref.invalidate(getCouponsProvider);
    }

    state = state.copyWith(dependenciesStatus: AppDependenciesStatus.ready);
  }







  Future<void> _disposeUserDependencies() async {
    _ref.invalidate(getMyOrdersProvider);
    _ref.invalidate(getMyAddressesProvider);
    _ref.invalidate(defaultAddressProvider);
    _ref.invalidate(getCouponsProvider);
    _ref.invalidate(getProfileProvider);
    _ref.invalidate(getMyCardsProvider);
    _ref.invalidate(getWalletInfoProvider);


    _ref.invalidate(defaultPaymentCardProvider);




    await CachePurger.purgeUserData();
  }
}
