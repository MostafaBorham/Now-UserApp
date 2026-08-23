import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/current_location_vm.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';
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
  ProviderSubscription<AsyncValue<PaginationModel<CategoryModel>>>?
      _appCategoriesSub;

  // Flipped once the logo animation ends; from then on the loader is shown
  // continuously — whatever happens in the background — until the splash leaves.
  bool _animationDone = false;

  // Latches once we navigate away, so a second listener firing (both the
  // session and the location gates settle independently) can never push twice.
  bool _navigated = false;

  // Latches once we decide to close the app on a refused location, so the exit
  // is requested only once.
  bool _closing = false;

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

    // Same warm-up for the (kept-alive) app-categories provider: preload the
    // first page here so the home carousel and categories screen reuse it. On
    // failure, drop the subscription and invalidate the errored instance so it
    // is recreated (and refetched) the next time a screen opens it.
    _appCategoriesSub = ref.listenManual(
      getAppCategoriesProvider,
      (
        AsyncValue<PaginationModel<CategoryModel>>? previous,
        AsyncValue<PaginationModel<CategoryModel>> next,
      ) {
        if (next is AsyncError) {
          _appCategoriesSub?.close();
          _appCategoriesSub = null;
          ref.invalidate(getAppCategoriesProvider);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    // Two independent gates must both settle before the splash may leave: the
    // session orchestrator's dependencies, and the guaranteed current location.
    ref.listen(
      authSessionProvider.select((s) => s.dependenciesStatus),
      (AppDependenciesStatus? previous, AppDependenciesStatus next) =>
          _maybeLeaveSplash(),
    );
    ref.listen(
      currentLocationProvider,
      (CurrentLocationStatus? previous, CurrentLocationStatus next) {
        // A refused location means there is nothing to enter the app with:
        // close it. Otherwise, re-check whether both gates are ready.
        if (next == CurrentLocationStatus.declined) {
          _closeApp();
        } else {
          _maybeLeaveSplash();
        }
      },
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
            // Once the logo settles, the loader spins continuously until the
            // splash leaves — regardless of any background work (data, location,
            // permissions).
            if (_animationDone)
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
    _appCategoriesSub?.close();
    _logoController.removeStatusListener(_logoAnimationListener);
    _logoController.dispose();
    super.dispose();
  }

  void _logoAnimationListener(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _animationDone = true);
      _warmUp();
    }
  }

  void _warmUp() {
    // Both bootstraps run in parallel; the splash leaves only once both settle
    // (see [_maybeLeaveSplash]). Location resolution requests its own service
    // prompt and permission as part of fetching the current fix.
    ref.read(currentLocationProvider.notifier).resolve();
    ref.read(authSessionProvider.notifier).resolveSession();
  }

  void _maybeLeaveSplash() {
    if (_navigated || _closing || !mounted) return;

    final bool dependenciesReady =
        ref.read(authSessionProvider).dependenciesStatus ==
            AppDependenciesStatus.ready;
    final bool locationReady =
        ref.read(currentLocationProvider) == CurrentLocationStatus.ready;

    if (dependenciesReady && locationReady) {
      _navigated = true;
      context.goNamed(AppRoutes.onBoardingScreen);
    }
  }

  void _closeApp() {
    if (_closing) return;
    _closing = true;
    SystemNavigator.pop();
  }
}
