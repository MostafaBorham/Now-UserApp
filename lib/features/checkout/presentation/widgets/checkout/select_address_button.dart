import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';




class SelectAddressButton extends StatelessWidget {
  const SelectAddressButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.onPrimaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  Text(
                    LangKeys.addNewAddress.tr(),
                    style: AppTextStyles.style16Medium.copyWith(
                      color: colors.tertiaryContainer,
                    ),
                  ),
                  Text(
                    LangKeys.noDeliveryAddressSelectedKey.tr(),
                    style: AppTextStyles.style14Regular.copyWith(
                      color: colors.red300Main,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.red300Main,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, size: 16, color: colors.red300Main),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
