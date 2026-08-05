import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';
import 'package:nowdelivery_user_app/features/welcome/data/datasources/local/cache/welcome_cache_service.dart';

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
                  child: CircularProgressIndicator(color: colors.secondary600),
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

  /// Once the logo animation ends, warm up the app and, when done, move on to
  /// the next screen.
  ///
  /// - Orders are prefetched **from the server** ([GetMyOrdersViewModel.loadOrders]
  ///   fetches the first page over the network — orders are server-only, no
  ///   cache) **only for a signed-in user**. A guest or no session at all has no
  ///   orders to load, so the request is skipped entirely.
  /// - Cart and addresses are **not** fetched here — each is loaded lazily the
  ///   first time a screen that needs it opens.
  Future<void> _initAppDependencies() async {
    setState(() => showLoader = true);
    await Future.wait(<Future<void>>[
      LocationManager.requestPermissions(),
      if (_hasUserSession())
        ref.read(getMyOrdersProvider.notifier).loadOrders(),
    ]).whenComplete(() {
      if (mounted) {
        context.goNamed(AppRoutes.onBoardingScreen);
      }
    });
  }

  /// `true` only for a signed-in user — a non-empty token cached with
  /// `isGuest == false`. A guest session or no session at all returns `false`.
  /// Mirrors the session check the router uses to gate logged-in-only routes.
  bool _hasUserSession() {
    final Map<String, dynamic> tokenData = WelcomeCacheService().getToken();
    final String token = tokenData[CacheKeys.tokenValue] as String? ?? '';
    final bool isGuest = tokenData[CacheKeys.isGuest] as bool? ?? true;

    return token.isNotEmpty && !isGuest;
  }
}
