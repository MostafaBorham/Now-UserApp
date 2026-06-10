import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        children: [
          Assets.media.images.svg.onboardingBackground.svg(
            fit: BoxFit.cover,
            width:  double.infinity,
            height: double.infinity,
          ),
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: SafeArea(
              child: Assets.media.images.png.onboardingImg.image(
                fit: BoxFit.contain,
                width: MediaQuery.sizeOf(context).width*0.9,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(30),
              width: double.infinity,
              height: MediaQuery.sizeOf(context).height*0.5,
              decoration: BoxDecoration(
                color: colors.onPrimary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: Border.symmetric(horizontal: BorderSide(
                  color: colors.inversePrimary.withValues(alpha: 0.3)
                ))
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 30,
                children: [
                  Assets.media.images.svg.appLogo.svg(
                    fit: BoxFit.contain,
                    width: MediaQuery.sizeOf(context).width*0.7,
                  ),
                  Text('تسوّق كل ما تحتاجه بالطريقة التي تناسبك',style: textThemes.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSecondary
                  ),overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,maxLines: 2,),
                  Text('احصل على كل ما تحتاجه بسهولة وسرعة، من خلال تطبيق واحد.',style: textThemes.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600
                  ),overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,maxLines: 2,),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                    decoration: ShapeDecoration(
                      color: colors.primary ,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Text(
                          'تسجيل الدخول',
                          textAlign: TextAlign.center,
                          style: textThemes.titleMedium?.copyWith(

                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  strokeAlign: BorderSide.strokeAlignCenter,
                                  color: colors.inversePrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'أو',
                          textAlign: TextAlign.center,
                          style: textThemes.labelMedium?.copyWith(
                            color: colors.inversePrimary.withValues(alpha: 0.5),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  strokeAlign: BorderSide.strokeAlignCenter,
                                  color: colors.inversePrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                    decoration: ShapeDecoration(
                      color: colors.onPrimary ,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),side: BorderSide(color: colors.primary,width: 2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Text(
                          'المتابعة كضيف',
                          textAlign: TextAlign.center,
                          style: textThemes.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
