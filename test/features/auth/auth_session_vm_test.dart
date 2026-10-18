import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_order_to_rate_vm.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Each fake's request settles when its gate does.

class _Profile extends GetProfileViewModel {
  _Profile(this._gate);
  final Future<void> _gate;
  @override
  Future<void> getProfile() => _gate;
}

class _Orders extends GetMyOrdersViewModel {
  _Orders(this._gate);
  final Future<void> _gate;
  @override
  Future<void> loadFirstPage() => _gate;
}

class _OrderToRate extends GetOrderToRateViewModel {
  _OrderToRate(this._gate);
  final Future<void> _gate;
  @override
  Future<void> getOrderToRate() => _gate;
}

class _Addresses extends GetMyAddressesViewModel {
  _Addresses(this._gate);
  final Future<void> _gate;
  @override
  Future<void> loadFirstPage() => _gate;
}

class _DefaultAddress extends DefaultAddressViewModel {
  _DefaultAddress(super.ref);
  @override
  Future<void> getDefaultAddress() async {}
}

class _Cart extends GetCartViewModel {
  _Cart(this._gate) : super(const AsyncValue.loading());
  final Future<void> _gate;
  @override
  Future<void> getCart() => _gate;
}

void main() {
  test('the splash is held for the profile alone; login still waits for all', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SharedPrefManager.init();
    await TokenCacheService().saveUserTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
    );

    final Completer<void> profile = Completer<void>();
    final Completer<void> rest = Completer<void>();
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        getProfileProvider.overrideWith((Ref ref) => _Profile(profile.future)),
        getMyOrdersProvider.overrideWith((Ref ref) => _Orders(rest.future)),
        getOrderToRateProvider.overrideWith(
          (Ref ref) => _OrderToRate(rest.future),
        ),
        getMyAddressesProvider.overrideWith(
          (Ref ref) => _Addresses(rest.future),
        ),
        defaultAddressProvider.overrideWith(_DefaultAddress.new),
        getCartProvider.overrideWith((Ref ref) => _Cart(rest.future)),
      ],
    );
    addTearDown(container.dispose);
    AppDependenciesStatus status() =>
        container.read(authSessionProvider).dependenciesStatus;
    Future<void> settle() => Future<void>.delayed(Duration.zero);

    bool loginDone = false;
    container
        .read(authSessionProvider.notifier)
        .resolveSession(awaitDependencies: true)
        .then((_) => loginDone = true);
    await settle();
    expect(status(), AppDependenciesStatus.loading);

    profile.complete();
    await settle();
    expect(status(), AppDependenciesStatus.ready);
    expect(loginDone, isFalse);

    rest.complete();
    await settle();
    expect(loginDone, isTrue);
  });
}
