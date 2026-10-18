import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/enums/session_types.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/current_location_vm.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';
import 'package:nowdelivery_user_app/features/promotion/viewmodel/get_welcome_voucher_vm.dart';
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
  ProviderSubscription<AsyncValue<CouponModel>>? _welcomeVoucherSub;

  // Flipped once the logo animation ends. The splash never leaves before, so
  // the branding is never cut short; the loader shows from then on only while
  // something the splash waits for is still pending.
  bool _logoDone = false;

  // Latches once we navigate away, so the logo ending and the session settling
  // can never both push.
  bool _navigated = false;

  // The controller's duration is only set inside Lottie's `onLoaded`, so if the
  // asset never decodes the animation never starts, never completes, and the
  // app would sit on the splash forever. This ends the logo anyway. Cancelled
  // once the asset loads — the animation (3 s) would otherwise lose its last
  // frames to it.
  Timer? _logoFallback;
  static const Duration _logoFallbackDelay = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this);
    _logoController.addStatusListener(_logoAnimationListener);
    _logoFallback = Timer(_logoFallbackDelay, _onLogoDone);

    // The session — and, for a signed-in user, the profile the splash waits
    // for — loads while the logo plays, so there is usually nothing left to
    // wait for when it ends.
    ref.read(authSessionProvider.notifier).resolveSession();

    // Always warm up the (kept-alive) application-information provider here so
    // the FAQ/privacy screens reuse the data instead of refetching. If the
    // warm-up fails, drop this subscription first, then invalidate the errored
    // instance — so it is disposed with no listeners and gets recreated (and
    // refetched) automatically the next time a screen opens it, rather than
    // inheriting the cached error.
    _appInfoSub = ref.listenManual(getAppInfoProvider, (
      AsyncValue<AppInfoModel>? previous,
      AsyncValue<AppInfoModel> next,
    ) {
      if (next is AsyncError) {
        _appInfoSub?.close();
        _appInfoSub = null;
        _invalidateAfterNotify(getAppInfoProvider);
      }
    });

    // Same warm-up for the (kept-alive) app-categories provider: preload the
    // first page here so the home carousel and categories screen reuse it. On
    // failure, drop the subscription and invalidate the errored instance so it
    // is recreated (and refetched) the next time a screen opens it.
    _appCategoriesSub = ref.listenManual(getAppCategoriesProvider, (
      AsyncValue<PaginationModel<CategoryModel>>? previous,
      AsyncValue<PaginationModel<CategoryModel>> next,
    ) {
      if (next is AsyncError) {
        _appCategoriesSub?.close();
        _appCategoriesSub = null;
        _invalidateAfterNotify(getAppCategoriesProvider);
      }
    });

    // Warm up the (kept-alive) welcome-voucher provider so the empty cart and
    // guest settings reuse the code instead of refetching. It errors when the
    // server refuses the code (switched off) or, offline, with no cached code —
    // in which case drop the subscription and invalidate the errored instance so
    // it is recreated (and refetched) the next time a screen opens it.
    _welcomeVoucherSub = ref.listenManual(welcomeVoucherProvider, (
      AsyncValue<CouponModel>? previous,
      AsyncValue<CouponModel> next,
    ) {
      if (next is AsyncError) {
        _welcomeVoucherSub?.close();
        _welcomeVoucherSub = null;
        _invalidateAfterNotify(welcomeVoucherProvider);
      }
    });
  }

  /// Invalidates a warm-up provider after the notification that reported its
  /// error, not inside it: disposing a StateNotifier from its own listener loop
  /// throws "Concurrent modification during iteration" — which a welcome code
  /// the server refuses triggered on every start.
  void _invalidateAfterNotify(ProviderOrFamily provider) =>
      Future<void>.microtask(() {
        if (mounted) ref.invalidate(provider);
      });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    // The one gate besides the logo: what the session orchestrator holds the
    // splash for (see [AppDependenciesStatus.ready]).
    ref.listen(
      authSessionProvider.select((s) => s.dependenciesStatus),
      (AppDependenciesStatus? previous, AppDependenciesStatus next) =>
          _maybeLeaveSplash(),
    );
    final bool waiting =
        _logoDone &&
        ref.watch(authSessionProvider.select((s) => s.dependenciesStatus)) !=
            AppDependenciesStatus.ready;

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
                  _logoFallback?.cancel();
                  _logoController
                    ..duration = composition.duration
                    ..forward();
                },
              ),
            ),
            if (waiting)
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
    _logoFallback?.cancel();
    _appInfoSub?.close();
    _appCategoriesSub?.close();
    _welcomeVoucherSub?.close();
    _logoController.removeStatusListener(_logoAnimationListener);
    _logoController.dispose();
    super.dispose();
  }

  void _logoAnimationListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) _onLogoDone();
  }

  void _onLogoDone() {
    // Reached from the animation finishing *or* from [_logoFallback], so it
    // has to be idempotent.
    if (_logoDone || !mounted) return;
    _logoFallback?.cancel();
    setState(() => _logoDone = true);

    // The splash does not wait for the location: Home holds its feed until
    // this pass ends. Started only now so its service and permission prompts
    // never cover the logo.
    ref.read(currentLocationProvider.notifier).resolve();
    _maybeLeaveSplash();
  }

  void _maybeLeaveSplash() {
    if (_navigated || !_logoDone || !mounted) return;
    if (ref.read(authSessionProvider).dependenciesStatus !=
        AppDependenciesStatus.ready) {
      return;
    }

    _navigated = true;
    context.goNamed(
      _needsProfileCompletion
          ? AppRoutes.completeProfileScreen
          : AppRoutes.onBoardingScreen,
    );
  }

  /// Whether this boot has to divert to the profile-completion screen.
  ///
  /// The OTP hop alone would leave a hole: the completion screen is mandatory,
  /// but force-quitting on it and relaunching would otherwise go
  /// splash → onboarding → main, straight past the step. The profile is already
  /// loaded by then — `_loadUserDependencies` fetches it and the splash waits
  /// for it — so this costs no extra request.
  ///
  /// Every unknown is read as "no gate": a guest, a profile that failed to
  /// load, or a payload without the flag. A missing flag must never strand a
  /// user who has nothing left to complete; the next login still gates them.
  bool get _needsProfileCompletion {
    if (ref.read(authSessionProvider).sessionType != SessionType.user) {
      return false;
    }
    return ref.read(getProfileProvider).valueOrNull?.profile.profileCompleted ==
        false;
  }
}
