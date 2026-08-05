import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoController;

  bool showLoader = false;

  /// Guards against a second navigation once the dependencies are ready (the
  /// listener could otherwise fire again on a later state change).
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this);
    _logoController.addStatusListener(_logoAnimationListener);
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    // The circular loader below is driven by the orchestrator: while it fetches
    // the logged-in user's dependencies the state is `loading`, and the moment
    // they all settle (or there are none, for a guest) it turns `ready` — which
    // is our cue to leave for onboarding.
    ref.listen(authSessionProvider.select((s) => s.dependenciesStatus), (
      AppDependenciesStatus? previous,
      AppDependenciesStatus next,
    ) {
      if (next == AppDependenciesStatus.ready) {
        _goToOnboarding();
      }
    });

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
      _warmUp();
    }
  }

  /// Once the logo animation ends, show the loader and warm the app up: request
  /// the (splash-scoped) location permissions, then hand off to the session
  /// orchestrator — this is the first time [AuthSessionViewModel.resolveSession]
  /// is needed, so we trigger it here. We do **not** await it: navigation is
  /// driven by the `ready` status the loader is listening to in [build], which
  /// lands once every session-dependent request has settled (immediately, for a
  /// guest, since it has none).
  Future<void> _warmUp() async {
    setState(() => showLoader = true);

    await LocationManager.requestPermissions();

    if (!mounted) return;

    ref.read(authSessionProvider.notifier).resolveSession();
  }

  /// Leaves for onboarding exactly once, when the orchestrator reports its
  /// dependencies are ready.
  void _goToOnboarding() {
    if (_navigated || !mounted) return;
    _navigated = true;
    context.goNamed(AppRoutes.onBoardingScreen);
  }
}
