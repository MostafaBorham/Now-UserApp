import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
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
    final ColorScheme colors = Theme.of(context).colorScheme;
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
      setState(() => showLoader = true);
      context.goNamed(AppRoutes.onBoardingScreen);
    }
  }
}
