import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// One option group on the product page (a colour, a size): a bordered card
/// whose title names the value picked — "Color: Red" — so each choice stands
/// out from the page around it (BUG-016).
class ProductOptionGroup extends StatelessWidget {
  const ProductOptionGroup({
    super.key,
    required this.title,
    required this.picked,
    required this.child,
    this.isRequired = true,
  });

  final String title;
  final String picked;
  final bool isRequired;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Row(
            spacing: 4,
            children: [
              Flexible(
                child: Text.rich(
                  TextSpan(
                    text: title,
                    style: AppTextStyles.style16Bold.copyWith(
                      color: colors.black,
                    ),
                    children: [
                      if (picked.isNotEmpty)
                        TextSpan(
                          text: ': $picked',
                          style: AppTextStyles.style16Medium.copyWith(
                            color: colors.primary500Main,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (isRequired)
                Text.rich(
                  TextSpan(
                    text: '(${LangKeys.selectRequiredKey.tr()}) ',
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
          child,
        ],
      ),
    );
  }
}
