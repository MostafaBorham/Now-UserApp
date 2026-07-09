import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_colors.dart';

/// Outlined "Add New Card" action shown beneath the form — a light bordered
/// button with a leading plus-circle icon.
class AddNewCardButton extends StatelessWidget {
  const AddNewCardButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.brCircular12,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppBorderRadius.brCircular12,
          border: Border.all(color: AppColors.outlinedButtonBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.media.images.svg.addCircleBlack.svg(width: 22, height: 22),
            const SizedBox(width: 8),
            Text(
              LangKeys.addNewCardKey.tr(),
              style: AppTextStyles.style16Medium.copyWith(
                color: AppColors.sectionTitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
