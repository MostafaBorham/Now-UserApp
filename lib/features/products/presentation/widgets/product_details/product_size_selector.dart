import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_selector.dart';

class ProductSizeSelector extends StatefulWidget {
  const ProductSizeSelector({
    super.key,
    this.title = 'Choose Color',
    this.hint = '(Select required) ',
    this.isRequired = true,
    this.colorOptions = const [
      (color: Color(0xff2C4A6E), name: 'Blue'),
      (color: Color(0xffD9D9DE), name: 'Silver'),
      (color: Color(0xffE8C9A0), name: 'Gold'),
      (color: Color(0xff5C5C60), name: 'Astronaut Gray'),
    ],
    this.initialSelectedIndex = 0,
    this.onColorSelected,
  });

  final String title;
  final String hint;
  final bool isRequired;
  final List<({Color color, String name})> colorOptions;
  final int initialSelectedIndex;
  final ValueChanged<int>? onColorSelected;

  @override
  State<ProductSizeSelector> createState() => _ProductSizeSelectorState();
}

class _ProductSizeSelectorState extends State<ProductSizeSelector> {
  late int selectedIndex = widget.initialSelectedIndex;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
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
              'Size',
              style: AppTextStyles.style16Bold.copyWith(
                color: colors.onSecondary,
              ),
            ),
            if (widget.isRequired)
              Text.rich(
                TextSpan(
                  text: widget.hint,
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
          items: ['16 inch', '15 inch', '17 inch', '16 inch'],
          initialIndex: 0,
          selectedColor: colors.tertiaryContainer,
          unselectedColor: colors.onPrimary,
          borderColor: colors.onSurface.withValues(alpha: 0.3),
          radius: 14,
          height: 45
        ),
      ],
    );
  }
}
