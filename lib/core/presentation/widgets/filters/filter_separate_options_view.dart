import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/enums/separate_option.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class FilterSeparateOptionsView extends StatefulWidget {
  const FilterSeparateOptionsView({super.key, this.onChanged});

  final ValueChanged<SeparateOption>? onChanged;

  @override
  State<FilterSeparateOptionsView> createState() =>
      _FilterSeparateOptionsViewState();
}

class _FilterSeparateOptionsViewState extends State<FilterSeparateOptionsView> {
  SeparateOption? selected;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final List<SeparateOption> options = SeparateOption.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          LangKeys.separateOptionsKey.tr(),
          style: AppTextStyles.style16Medium.copyWith(
            color: colors.neutral1200,
          ),
        ),
        ...List.generate((options.length / 2).ceil(), (row) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: List.generate(2, (col) {
              final int index = row * 2 + col;
              if (index >= options.length) {
                return const Expanded(child: SizedBox.shrink());
              }
              final SeparateOption option = options[index];
              final bool isSelected = option == selected;
              return Expanded(
                child: InkWell(
                  borderRadius: AppBorderRadius.brCircular30,
                  onTap: () {
                    setState(() => selected = option);
                    widget.onChanged?.call(option);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.secondaryFixed
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? null
                              : Border.all(color: colors.neutral400),
                        ),
                        child: isSelected
                            ? FittedBox(
                                child: Icon(
                                  Icons.check_outlined,
                                  color: colors.white,
                                ),
                              )
                            : null,
                      ),
                      Expanded(
                        child: Text(
                          option.label,
                          maxLines: 2,
                          style: AppTextStyles.style14Regular.copyWith(
                            color: colors.neutral1200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }
}
