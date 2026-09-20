import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// "Set as default card" toggle shown on the add-card forms. When left on, the
/// screen promotes the just-added card through the set-default endpoint after it
/// is created (the backend auto-defaults only the very first card).
class SetAsDefaultCheckbox extends StatelessWidget {
  const SetAsDefaultCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.labelColor,
  });

  final bool value;

  /// Null disables the toggle (e.g. while the save is in flight).
  final ValueChanged<bool>? onChanged;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged:
                onChanged == null ? null : (bool? v) => onChanged!(v ?? false),
            activeColor: colors.primary500Main,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              LangKeys.setAsDefaultKey.tr(),
              style: AppTextStyles.style14Medium.copyWith(
                color: labelColor ?? colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
