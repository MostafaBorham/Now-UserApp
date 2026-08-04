import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class AddNotesField extends StatelessWidget {
  const AddNotesField({super.key, this.onChanged});

  /// Reports the note text on every keystroke; the parent owns the value.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return TextFormField(
      onChanged: onChanged,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      minLines: 3,
      style: AppTextStyles.style16Medium.copyWith(
          color: colors.onSecondary
      ),
      maxLines: 8,
      decoration: InputDecoration(
        hintText: LangKeys.addNotesHintKey.tr(),
        hintStyle: AppTextStyles.style16Medium.copyWith(
            color: colors.onSurface.withValues(alpha: 0.7)
        ),
        filled: true,
        fillColor: colors.onSurface.withValues(alpha: 0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
