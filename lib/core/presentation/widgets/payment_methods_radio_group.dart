import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// A single payment method entry passed to [PaymentMethodsRadioGroup].
///
/// A plain record (no model class): [icon] and [color] describe the brand
/// badge, [solid] fills the circle with [color] (e.g. Apple Pay black) instead
/// of a light tint, and [subtitle] is optional supporting text.
typedef PaymentMethodEntry = ({
  IconData icon,
  Color color,
  bool solid,
  String title,
  String? subtitle,
});

/// A single-select list of payment method rows. Each row shows a brand badge,
/// a title with an optional subtitle, and a radio-style indicator that fills
/// green when selected.
///
/// Controlled widget: the parent owns [selectedIndex] and is notified through
/// [onChanged].
class PaymentMethodsRadioGroup extends StatelessWidget {
  const PaymentMethodsRadioGroup({
    super.key,
    required this.methods,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<PaymentMethodEntry> methods;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        ...methods.indexed.map((entry) {
          final int index = entry.$1;
          final PaymentMethodEntry method = entry.$2;
          final bool selected = index == selectedIndex;
          return InkWell(
            onTap: () => onChanged(index),
            borderRadius: AppBorderRadius.brCircular12,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.primaryFixed,
                borderRadius: AppBorderRadius.brCircular12,
              ),
              child: Row(
                spacing: 12,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: method.solid
                          ? method.color
                          : method.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      method.icon,
                      size: 24,
                      color: method.solid ? colors.onPrimary : method.color,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 2,
                      children: [
                        Text(
                          method.title,
                          style: AppTextStyles.style16Medium.copyWith(
                            color: colors.tertiaryContainer,
                          ),
                        ),
                        if (method.subtitle != null)
                          Text(
                            method.subtitle!,
                            style: AppTextStyles.style14Regular.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? colors.primary
                            : colors.surfaceContainerLow,
                        width: 1.5,
                      ),
                    ),
                    child: selected
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
