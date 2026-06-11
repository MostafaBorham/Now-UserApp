import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/components/field_input_borders.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/app_logo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colors.onSecondaryFixed,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                spacing: 15,
                children: [
                  AppLogo(size: 134.sp),
                  Column(
                    children: [
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 25.w,
                            backgroundColor: Colors.transparent,
                            child: CachedNetworkImage(
                              imageUrl: '',
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(
                                    padding: EdgeInsets.all(10),
                                    backgroundColor: colors.onPrimary,
                                    color: colors.primary,
                                  ),
                              errorWidget: (context, url, error) => Assets
                                  .media
                                  .images
                                  .png
                                  .profileImgPlacholder
                                  .image(fit: BoxFit.cover),
                            ),
                          ),
                          Column(
                            spacing: 4,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                'guest 123',
                                style: AppTextStyles.style20SemiBold,
                                maxLines: 1,
                              ),
                              Row(
                                spacing: 5,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Assets.media.images.svg.locationIcon.svg(
                                    width: 15.w,
                                  ),
                                  AutoSizeText(
                                    'gada, saudia 23 st',
                                    style: AppTextStyles.style12Regular,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Spacer(),
                          Badge.count(
                            count: 2,
                            padding: EdgeInsets.all(5),
                            child: Assets.media.images.svg.alertIcon.svg(
                              width: 30.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(25),
                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                        filled: true,
                        fillColor: colors.onPrimary,
                        prefixIconConstraints:BoxConstraints(
                          maxWidth: 50,
                          maxHeight: 50,
                          minHeight: 30,
                          minWidth: 30
                        ),
                        prefixIcon: Assets.media.images.svg.searchIcon.svg(),
                        hintText: LangKeys.searchNowKey.tr(),
                        hintStyle: AppTextStyles.style16Regular,
                        enabledBorder: customInputBorder1,
                        focusedBorder: customInputBorder1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
