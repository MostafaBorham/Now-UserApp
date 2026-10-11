import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_selector.dart';
import 'package:nowdelivery_user_app/features/products/data/models/product_attribute_model.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_option_group.dart';

class ProductSizeSelector extends StatefulWidget {
  const ProductSizeSelector({
    super.key,
    required this.attribute,
    this.isRequired = true,
    this.initialSelectedIndex = 0,
    this.onValueSelected,
  });

  final ProductAttributeModel attribute;
  final bool isRequired;
  final int initialSelectedIndex;

  final ValueChanged<ProductAttributeValueModel>? onValueSelected;

  @override
  State<ProductSizeSelector> createState() => _ProductSizeSelectorState();
}

class _ProductSizeSelectorState extends State<ProductSizeSelector> {
  late int _selected = widget.initialSelectedIndex;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final List<ProductAttributeValueModel> values =
        widget.attribute.values ?? [];
    final List<String> options = values
        .map((value) => context.getLocalizedApiText(value.name))
        .toList();
    return ProductOptionGroup(
      title: context.getLocalizedApiText(widget.attribute.name),
      picked: _selected < options.length ? options[_selected] : '',
      isRequired: widget.isRequired,
      child: AppSelector(
        items: options,
        initialIndex: widget.initialSelectedIndex,
        selectedColor: colors.tertiaryContainer,
        unselectedColor: colors.white,
        borderColor: colors.neutral500.withValues(alpha: 0.3),
        radius: 14,
        height: 45,
        onChanged: (index) {
          setState(() => _selected = index);
          widget.onValueSelected?.call(values[index]);
        },
      ),
    );
  }
}
