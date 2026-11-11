import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class FilterViewHeader extends StatelessWidget {
  const FilterViewHeader({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.dividerLight)),
      ),
      child: Column(
        spacing: 16,
        children: [
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: colors.neutral200,
              borderRadius: AppBorderRadius.brCircular2,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  LangKeys.filterKey.tr(),
                  style: AppTextStyles.style20Bold.copyWith(
                    color: colors.neutral1200,
                  ),
                ),
              ),
              InkResponse(
                onTap: onClose,
                radius: 16,
                child: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: colors.tertiaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
