import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/products/data/models/product_color_model.dart';

class ProductColorsSelector extends StatefulWidget {
  const ProductColorsSelector({
    super.key,
    required this.colors,
    this.title,
    this.hint,
    this.isRequired = true,
    this.initialSelectedIndex = 0,
    this.onColorSelected,
  });

  final List<ProductColorModel> colors;
  final String? title;
  final String? hint;
  final bool isRequired;
  final int initialSelectedIndex;

  final ValueChanged<ProductColorModel>? onColorSelected;

  @override
  State<ProductColorsSelector> createState() => _ProductColorsSelectorState();
}

class _ProductColorsSelectorState extends State<ProductColorsSelector> {
  late int selectedIndex = widget.initialSelectedIndex;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final String title = widget.title ?? LangKeys.chooseColorKey.tr();
    final String hint = widget.hint ?? LangKeys.selectRequiredKey.tr();
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
                color: colors.black,
              ),
            ),
            if (widget.isRequired)
              Text.rich(
                TextSpan(
                  text: '($hint) ',
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
            children: List.generate(widget.colors.length, (index) {
              final ProductColorModel option = widget.colors[index];
              final Color swatch = option.color ?? colors.neutral200;
              final String name = context.getLocalizedApiText(option.name);
              final bool isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () {
                  setState(() => selectedIndex = index);
                  widget.onColorSelected?.call(option);
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
                                ? Border.all(color: colors.primary500Main, width: 2)
                                : Border.all(color: Colors.transparent, width: 2),
                          ),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: swatch,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        if(isSelected)Container(
                          decoration: BoxDecoration(
                            color: colors.primary500Main,
                            shape: BoxShape.circle,
                            border: Border.all(width: 2,color: colors.white)
                          ),
                          child: Center(child: Icon(Icons.check,color: colors.white,size: 15,)),
                        )
                      ],
                    ),
                    Text(
                      name,
                      style:
                          (isSelected
                                  ? AppTextStyles.style12SemiBold
                                  : AppTextStyles.style12Regular)
                              .copyWith(
                                fontSize: 11,
                                color: isSelected
                                    ? colors.black
                                    : colors.neutral500,
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
