import 'package:auto_size_text/auto_size_text.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/common/route/app_routes.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/widgets/onboarding/onboarding_login_navigator_widget.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/logos/app_logo.dart';

import '../../widgets/onboarding/or_divider.dart';
import '../../widgets/shared/buttons/primary_app_button.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
