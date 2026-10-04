import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/local/current_location_cache_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/current_location_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_order_to_rate_vm.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';
import 'package:shared_preferences/shared_preferences.dart';

const MethodChannel _geolocator = MethodChannel(
  'flutter.baseflow.com/geolocator',
);
const MethodChannel _location = MethodChannel('lyokone/location');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final TestDefaultBinaryMessenger messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final CurrentLocationCacheService cache = CurrentLocationCacheService();
  late List<String> calls;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SharedPrefManager.init();
    calls = <String>[];
    // GPS off, and the user refuses to switch it on.
    messenger.setMockMethodCallHandler(_geolocator, (MethodCall call) async {
      calls.add(call.method);
      return call.method == 'isLocationServiceEnabled' ? false : null;
    });
    messenger.setMockMethodCallHandler(_location, (MethodCall call) async {
      calls.add(call.method);
      return 0;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(_geolocator, null);
    messenger.setMockMethodCallHandler(_location, null);
  });

  test('GPS off, nothing cached, prompt refused: no made-up location '
      '(BUG-003)', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(currentLocationProvider.notifier).resolve();

    expect(calls, contains('requestService'));
    expect(cache.getCurrentLocation(), isNull);
    expect(
      container.read(currentLocationProvider),
      CurrentLocationStatus.ready,
    );
  });

  test('a re-check without a prompt never asks to switch GPS on', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(currentLocationProvider.notifier)
        .resolve(prompt: false);

    expect(calls, isNot(contains('requestService')));
    expect(
      container.read(currentLocationProvider),
      CurrentLocationStatus.ready,
    );
  });

  test(
    'a session change forgets the previous user\'s location (BUG-004)',
    () async {
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          getMyOrdersProvider.overrideWith((Ref ref) => _NoOrders()),
          getOrderToRateProvider.overrideWith((Ref ref) => _NoOrderToRate()),
          getMyAddressesProvider.overrideWith((Ref ref) => _NoAddresses()),
          defaultAddressProvider.overrideWith((Ref ref) => _NoDefault(ref)),
          getProfileProvider.overrideWith((Ref ref) => _NoProfile()),
          getCartProvider.overrideWith((Ref ref) => _NoCart()),
        ],
      );
      addTearDown(container.dispose);
      final AuthSessionViewModel session = container.read(
        authSessionProvider.notifier,
      );

      // A guest boots, then confirms an address that gets cached.
      await session.resolveSession();
      await cache.saveCurrentLocation(
        const AddressModel(id: 7, latitude: '24.7', longitude: '46.6'),
      );

      // Login.
      await TokenCacheService().saveAccessToken('token');
      await session.resolveSession();

      expect(cache.getCurrentLocation(), isNull);
    },
  );
}

class _NoOrders extends GetMyOrdersViewModel {
  @override
  Future<void> loadFirstPage() async {}
}

class _NoOrderToRate extends GetOrderToRateViewModel {
  @override
  Future<void> getOrderToRate() async {}
}

class _NoAddresses extends GetMyAddressesViewModel {
  @override
  Future<void> loadFirstPage() async {}
}

class _NoDefault extends DefaultAddressViewModel {
  _NoDefault(super.ref);

  @override
  Future<void> getDefaultAddress() async {}
}

class _NoProfile extends GetProfileViewModel {
  @override
  Future<void> getProfile() async {}
}

class _NoCart extends GetCartViewModel {
  _NoCart() : super(const AsyncValue.loading());

  @override
  Future<void> getCart() async {}
}
