import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// A pill badge reading "Out of stock", shown in place of the cart control when
/// a product has no stock left. Red background, white text — shared by the
/// product cards and the product-details header.
class OutOfStockLabel extends StatelessWidget {
  const OutOfStockLabel({super.key, this.fontSize});

  /// Overrides the label font size; `null` keeps the base [AppTextStyles] size.
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: AppBorderRadius.brCircular8,
      ),
      child: Text(
        LangKeys.outOfStockKey.tr(),
        style: AppTextStyles.style12Medium.copyWith(
          color: colors.white,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
