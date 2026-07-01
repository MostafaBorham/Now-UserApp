import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:nowdelivery_user_app/common/localization/constants.dart';
import 'package:nowdelivery_user_app/common/localization/local_controller.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/features/welcome/presentation/widgets/onboarding/app_language_toggle_widget.dart';
import 'package:nowdelivery_user_app/features/welcome/presentation/widgets/onboarding/onboarding_content_view.dart';

class OnBoardingScreen extends ConsumerWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Svg(Assets.media.images.svg.onboardingBackground.path),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Assets.media.images.png.onboardingImg.image(),
                    ),
                  ),
                  OnBoardingContentView(),
                ],
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: AppLanguageToggleWidget(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.width * 0.1,
                    initialLanguage: context.locale == LocalizationConstants.arabicLocale? AppLanguage.ar : AppLanguage.en,
                    onChanged: (lang) {
                      if (lang == AppLanguage.ar) {
                        context.setLocale(LocalizationConstants.arabicLocale);
                      } else {
                        context.setLocale(LocalizationConstants.englishLocale);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
