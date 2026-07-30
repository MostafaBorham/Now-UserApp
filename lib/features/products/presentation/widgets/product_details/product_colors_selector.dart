import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class ProductColorsSelector extends StatefulWidget {
  const ProductColorsSelector({
    super.key,
    this.title,
    this.hint,
    this.isRequired = true,
    this.colorOptions,
    this.initialSelectedIndex = 0,
    this.onColorSelected,
  });

  final String? title;
  final String? hint;
  final bool isRequired;
  final List<({Color color, String name})>? colorOptions;
  final int initialSelectedIndex;
  final ValueChanged<int>? onColorSelected;

  @override
  State<ProductColorsSelector> createState() => _ProductColorsSelectorState();
}

class _ProductColorsSelectorState extends State<ProductColorsSelector> {
  late int selectedIndex = widget.initialSelectedIndex;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String title = widget.title ?? LangKeys.chooseColorKey.tr();
    final String hint = widget.hint ?? LangKeys.selectRequiredKey.tr();
    final List<({Color color, String name})> colorOptions =
        widget.colorOptions ??
        [
          (color: const Color(0xff2C4A6E), name: LangKeys.colorBlueKey.tr()),
          (color: const Color(0xffD9D9DE), name: LangKeys.colorSilverKey.tr()),
          (color: const Color(0xffE8C9A0), name: LangKeys.colorGoldKey.tr()),
          (
            color: const Color(0xff5C5C60),
            name: LangKeys.colorAstronautGrayKey.tr(),
          ),
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 16,
            children: List.generate(colorOptions.length, (index) {
              final ({Color color, String name}) option = colorOptions[index];
              final bool isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () {
                  setState(() => selectedIndex = index);
                  widget.onColorSelected?.call(index);
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.topEnd,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: colors.primary, width: 2)
                                : Border.all(color: Colors.transparent, width: 2),
                          ),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: option.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        if(isSelected)Container(
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(width: 2,color: colors.onPrimary)
                          ),
                          child: Center(child: Icon(Icons.check,color: colors.onPrimary,size: 15,)),
                        )
                      ],
                    ),
                    Text(
                      option.name,
                      style:
                          (isSelected
                                  ? AppTextStyles.style12SemiBold
                                  : AppTextStyles.style12Regular)
                              .copyWith(
                                fontSize: 11,
                                color: isSelected
                                    ? colors.onSecondary
                                    : colors.onSurface,
                              ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
