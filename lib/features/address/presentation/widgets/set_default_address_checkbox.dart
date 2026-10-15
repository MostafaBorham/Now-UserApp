import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// "Set as default address" toggle shown on the add/edit address form.
class SetDefaultAddressCheckbox extends StatelessWidget {
  const SetDefaultAddressCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;

  /// Null disables the toggle, for example while saving.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged == null
                ? null
                : (bool? v) => onChanged!(v ?? false),
            activeColor: colors.primary500Main,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              LangKeys.setAsDefaultAddressKey.tr(),
              style: AppTextStyles.style14Medium.copyWith(color: colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
