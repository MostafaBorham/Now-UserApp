import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/app_info_model.dart';
import 'package:nowdelivery_user_app/features/settings/viewmodel/get_app_info_vm.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoController;
  ProviderSubscription<AsyncValue<AppInfoModel>>? _appInfoSub;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this);
    _logoController.addStatusListener(_logoAnimationListener);

    // Always warm up the (kept-alive) application-information provider here so
    // the FAQ/privacy screens reuse the data instead of refetching. If the
    // warm-up fails, drop this subscription first, then invalidate the errored
    // instance — so it is disposed with no listeners and gets recreated (and
    // refetched) automatically the next time a screen opens it, rather than
    // inheriting the cached error.
    _appInfoSub = ref.listenManual(
      getAppInfoProvider,
      (AsyncValue<AppInfoModel>? previous, AsyncValue<AppInfoModel> next) {
        if (next is AsyncError) {
          _appInfoSub?.close();
          _appInfoSub = null;
          ref.invalidate(getAppInfoProvider);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    // Leave for onboarding the moment the orchestrator reports its
    // dependencies are ready (immediately for a guest, once every request has
    // settled for a logged-in user).
    ref.listen(authSessionProvider.select((s) => s.dependenciesStatus), (
      AppDependenciesStatus? previous,
      AppDependenciesStatus next,
    ) {
      if (next == AppDependenciesStatus.ready) {
        context.goNamed(AppRoutes.onBoardingScreen);
      }
    });

    // The loader is bound straight to the orchestrator's state: it shows only
    // while the logged-in user's dependencies are being fetched — no local flag.
    final bool isLoadingDependencies = ref.watch(
      authSessionProvider.select(
        (s) => s.dependenciesStatus == AppDependenciesStatus.loading,
      ),
    );

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
            if (isLoadingDependencies)
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
    _appInfoSub?.close();
    _logoController.removeStatusListener(_logoAnimationListener);
    _logoController.dispose();
    super.dispose();
  }

  void _logoAnimationListener(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      _warmUp();
    }
  }

  Future<void> _warmUp() async {
    await LocationManager.requestPermissions();

    if (!mounted) return;

    ref.read(authSessionProvider.notifier).resolveSession();
  }
}
