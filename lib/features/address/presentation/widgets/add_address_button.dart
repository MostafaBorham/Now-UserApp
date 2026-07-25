import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

import '../../../settings/app_colors.dart';

/// Full-width green call-to-action, with a leading "add" icon, used to create
/// a new saved address.
class AddAddressButton extends StatelessWidget {
  const AddAddressButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryGreen,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Assets.media.images.svg.addCircle.svg(width: 24, height: 24),
              const SizedBox(width: 10),
              Text(
                LangKeys.addNewAddress.tr(),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.buttonForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}