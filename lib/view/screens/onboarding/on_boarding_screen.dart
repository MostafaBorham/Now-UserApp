import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/widgets/onboarding/app_language_toggle_widget.dart';
import 'package:nowdelivery_user_app/view/widgets/onboarding/onboarding_login_navigator_widget.dart';


class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: Svg(Assets.media.images.svg.onboardingBackground.path),fit: BoxFit.cover)
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  Assets.media.images.png.onboardingImg.image(
                    width: screenWidth*0.9
                  ),
                  Expanded(child: OnBoardingLoginNavigatorWidget())
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: AppLanguageToggleWidget(
                  initialLanguage: AppLanguage.en,
                  onChanged: (lang) {
                    if (lang == AppLanguage.en) {
                      // English selected
                    } else {
                      // Arabic selected
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
    return Scaffold(
      body: Stack(
        children: [
          Assets.media.images.svg.onboardingBackground.svg(
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: SafeArea(
              child: Assets.media.images.png.onboardingImg.image(
                fit: BoxFit.contain,
                height: 400.w,
                width: 400.w,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: OnBoardingLoginNavigatorWidget(),
          ),
        ],
      ),
    );
  }
}
