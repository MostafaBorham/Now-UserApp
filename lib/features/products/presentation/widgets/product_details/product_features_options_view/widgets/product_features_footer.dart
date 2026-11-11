import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';

class ProductFeaturesFooter extends StatelessWidget {
  const ProductFeaturesFooter({super.key, this.onConfirm, this.onCancel});

  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  static final TextStyle _buttonTitleStyle = AppTextStyles.style18Medium;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(height: 1, thickness: 1, color: context.colors.neutral200),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                flex: 5,
                child: PrimaryAppButton(
                  title: LangKeys.confirmSelectionKey.tr(),
                  titleStyle: _buttonTitleStyle,
                  onTap: onConfirm,
                ),
              ),
              Expanded(
                flex: 2,
                child: UnPrimaryAppButton(
                  title: LangKeys.cancelKey.tr(),
                  titleStyle: _buttonTitleStyle,
                  onTap: onCancel,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
