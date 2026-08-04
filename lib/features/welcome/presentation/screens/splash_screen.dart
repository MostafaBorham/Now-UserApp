import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoController;

  bool showLoader = false;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this);
    _logoController.addStatusListener(_logoAnimationListener);
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFFB0F65F), Color(0xFF4BB749)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Assets.json.splash.lottie(
                repeat: false,
                controller: _logoController,
                onLoaded: (composition) {
                  _logoController
                    ..duration = composition.duration
                    ..forward();
                },
              ),
            ),
            if (showLoader)
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.sizeOf(context).width * 0.6,
                ),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.1,
                  height: MediaQuery.sizeOf(context).width * 0.1,
                  child: CircularProgressIndicator(color: colors.secondary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.removeStatusListener(_logoAnimationListener);
    _logoController.dispose();
    super.dispose();
  }

  void _logoAnimationListener(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      _initAppDependencies();
    }
  }

  /// Once the logo animation ends, kick off data loading and the location
  /// permission request together. We wait for both — including the user's
  /// allow/refuse response — before navigating to the next screen.
  ///
  /// Backend-backed dependencies (addresses, cart) are only fetched when a
  /// session token (guest or user) is already cached — with no token those
  /// requests can't authenticate, so we skip them entirely.
  Future<void> _initAppDependencies() async {
    setState(() => showLoader = true);
    final List<Future<void>> pending = <Future<void>>[
      LocationManager.requestPermissions(),
    ];
    if (_hasSessionToken()) {
      pending.addAll(<Future<void>>[
        ref.read(getMyAddressesProvider.notifier).getMyAddresses(),
        ref.read(getCartProvider.notifier).getCart(),
      ]);
    }
    await Future.wait(pending).whenComplete(() {
      if (mounted) {
        context.goNamed(AppRoutes.onBoardingScreen);
      }
    });
  }

  /// Returns `true` when a non-empty session token (guest or user) is cached.
  bool _hasSessionToken() {
    final String? raw = SharedPrefManager.getString(CacheKeys.token);
    if (raw == null || raw.isEmpty) return false;
    try {
      final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
      final String token = map[CacheKeys.tokenValue] as String? ?? '';
      return token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
