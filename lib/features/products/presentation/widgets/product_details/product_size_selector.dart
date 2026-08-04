import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_selector.dart';

class ProductSizeSelector extends StatefulWidget {
  const ProductSizeSelector({
    super.key,
    this.title,
    this.hint,
    this.isRequired = true,
    this.sizeOptions,
    this.initialSelectedIndex = 0,
    this.onSizeSelected,
  });

  final String? title;
  final String? hint;
  final bool isRequired;
  final List<String>? sizeOptions;
  final int initialSelectedIndex;
  final ValueChanged<int>? onSizeSelected;

  @override
  State<ProductSizeSelector> createState() => _ProductSizeSelectorState();
}

class _ProductSizeSelectorState extends State<ProductSizeSelector> {
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final String title = widget.title ?? LangKeys.sizeKey.tr();
    final String hint = widget.hint ?? LangKeys.selectRequiredKey.tr();
    final List<String> sizeOptions =
        widget.sizeOptions ??
        [
          LangKeys.size16InchKey.tr(),
          LangKeys.size15InchKey.tr(),
          LangKeys.size17InchKey.tr(),
          LangKeys.size16InchKey.tr(),
        ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            Text(
              title,
              style: AppTextStyles.style16Bold.copyWith(
                color: colors.onSecondary,
              ),
            ),
            if (widget.isRequired)
              Text.rich(
                TextSpan(
                  text: hint,
                  style: AppTextStyles.style10Medium.copyWith(
                    color: colors.onPrimaryFixed,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: colors.errorContainer),
                    ),
                  ],
                ),
              ),
          ],
        ),
        AppSelector(
          items: sizeOptions,
          initialIndex: widget.initialSelectedIndex,
          selectedColor: colors.tertiaryContainer,
          unselectedColor: colors.onPrimary,
          borderColor: colors.onSurface.withValues(alpha: 0.3),
          radius: 14,
          height: 45,
        ),
      ],
    );
  }
}
