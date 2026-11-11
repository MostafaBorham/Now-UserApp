import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/products/data/models/product_specification_model.dart';

class ProductBasicSpecificationsView extends StatelessWidget {
  const ProductBasicSpecificationsView({
    super.key,
    required this.specifications,
  });

  final List<ProductSpecificationModel> specifications;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Text(
          LangKeys.basicSpecificationsKey.tr(),
          style: AppTextStyles.style16Bold.copyWith(color: colors.black),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.onPrimaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.neutral200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < specifications.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: i == specifications.length - 1
                        ? null
                        : Border(bottom: BorderSide(color: colors.neutral200)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        context.getLocalizedApiText(specifications[i].key),
                        style: AppTextStyles.style14Regular.copyWith(
                          color: colors.neutral500,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          context.getLocalizedApiText(specifications[i].value),
                          textAlign: TextAlign.end,
                          style: AppTextStyles.style14SemiBold.copyWith(
                            color: colors.black,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
