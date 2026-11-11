import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class ProductFeaturesHeader extends StatelessWidget {
  const ProductFeaturesHeader({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      children: [
        Container(
          width: 50,
          height: 4,
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          decoration: BoxDecoration(
            color: colors.neutral200,
            borderRadius: AppBorderRadius.brCircular2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LangKeys.productOptionsKey.tr(),
                style: AppTextStyles.style20Bold.copyWith(
                  color: colors.neutral1200,
                ),
              ),
              GestureDetector(
                onTap: onClose,
                behavior: HitTestBehavior.opaque,
                child: Icon(Icons.close, size: 20, color: colors.neutral1200),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: colors.neutral200),
      ],
    );
  }
}
