import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';

class FilterActions extends StatelessWidget {
  const FilterActions({super.key, this.onApply, this.onReset});

  final VoidCallback? onApply;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.dividerLight)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: PrimaryAppButton(
                  title: LangKeys.applyKey.tr(),
                  titleStyle: AppTextStyles.style18Medium,
                  onTap: onApply,
                ),
              ),
              UnPrimaryAppButton(
                title: LangKeys.resetKey.tr(),
                titleStyle: AppTextStyles.style18Medium,
                onTap: onReset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
