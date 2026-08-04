import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';

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
  /// - Orders are prefetched **cache-first**: [GetMyOrdersViewModel.loadOrders]
  ///   reads Hive and only hits the API when nothing is cached, so a warm cache
  ///   costs no request here.
  /// - Cart and addresses are **not** fetched here — each is loaded lazily the
  ///   first time a screen that needs it opens.
  Future<void> _initAppDependencies() async {
    setState(() => showLoader = true);
    await Future.wait(<Future<void>>[
      LocationManager.requestPermissions(),
      ref.read(getMyOrdersProvider.notifier).loadOrders(),
    ]).whenComplete(() {
      if (mounted) {
        context.goNamed(AppRoutes.onBoardingScreen);
      }
    });
  }
}
