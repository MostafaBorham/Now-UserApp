import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:nowdelivery_user_app/core/localization/constants.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/features/welcome/presentation/widgets/onboarding/app_language_toggle_widget.dart';
import 'package:nowdelivery_user_app/features/welcome/presentation/widgets/onboarding/onboarding_content_view.dart';

class OnBoardingScreen extends ConsumerWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: false,
      resizeToAvoidBottomInset: false,
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
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  textDirection: TextDirection.ltr,
                  children: [
                    Assets.media.images.png.onboardingImg.image(
                      fit: BoxFit.fill,
                    ),
                    AppLanguageToggleWidget(
                      width: MediaQuery.of(context).size.width * 0.3,

                      initialLanguage:
                          context.locale == LocalizationConstants.arabicLocale
                          ? AppLanguage.ar
                          : AppLanguage.en,
                      onChanged: (lang) {
                        if (lang == AppLanguage.ar) {
                          context.setLocale(LocalizationConstants.arabicLocale);
                        } else {
                          context.setLocale(
                            LocalizationConstants.englishLocale,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              OnBoardingContentView(),
            ],
          ),
        ),
      ),
    );
  }
}
