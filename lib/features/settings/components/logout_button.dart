import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

import '../app_colors.dart';

/// Full-width red "Log Out" button with the provided logout icon.
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.logoutRed,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Assets.media.images.svg.logout.svg(width: 22, height: 22),
              const SizedBox(width: 12),
              Text(
                LangKeys.logout.tr(),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.logoutForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
