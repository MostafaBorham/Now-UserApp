import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_colors.dart';

/// White, shadowed field with a leading mobile icon, a small "Mobile Number"
/// label and a phone-number input.
class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({super.key, this.controller, this.hint});

  final TextEditingController? controller;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.brCircular16,
        border: Border.all(color: AppColors.outlinedButtonBorder),
        boxShadow: AppBoxShadows.greyElevation2,
      ),
      child: Row(
        children: [
          Assets.media.images.svg.mobile.svg(width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LangKeys.mobileNumberKey.tr(),
                  style: AppTextStyles.style14Regular.copyWith(
                    color: AppColors.mutedLabel,
                  ),
                ),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  style: AppTextStyles.style16Medium.copyWith(
                    color: AppColors.optionTitle,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    hintText: hint ?? '(239) 555-0108',
                    hintStyle: AppTextStyles.style16Medium.copyWith(
                      color: AppColors.mutedLabel,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.only(top: 4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
