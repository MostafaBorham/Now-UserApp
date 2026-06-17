import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';

class CategoriesHeader extends StatelessWidget {
  const CategoriesHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 153.h,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    colors.surfaceContainerHighest,
                    colors.surfaceContainer,
                    colors.onSecondaryFixed,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Assets.media.images.svg.categoriesHeaderWave.svg(
              fit: BoxFit.fill,
              height: 60.h,
              colorFilter: ColorFilter.mode(colors.onPrimary, BlendMode.srcIn),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(top: 8.h, left: 16.w, right: 16.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BackArrowButton(onTap: onBack),
                      Text(
                        LangKeys.categoriesTitleKey.tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.style28SemiBold.copyWith(
                          color: colors.tertiaryContainer,
                        ),
                      ),
                      SizedBox(width: 48,)
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackArrowButton extends StatelessWidget {
  const _BackArrowButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: colors.onPrimary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Transform.rotate(
          angle: isRtl ? 0 : 3.14159,
          child: Assets.media.images.svg.arrowBrokenIcon.svg(
            width: 20.w,
            height: 20.w,
            colorFilter: ColorFilter.mode(
              colors.tertiaryContainer,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
