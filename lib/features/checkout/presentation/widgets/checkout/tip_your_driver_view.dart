import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/counters/full_width_counter_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_selector.dart';

class TipYourDriverView extends StatefulWidget {
  const TipYourDriverView({super.key});

  @override
  State<TipYourDriverView> createState() => _TipYourDriverViewState();
}

class _TipYourDriverViewState extends State<TipYourDriverView> {
  bool showTipOtherCounterView = false;
  double tipAmount = 0;
  @override
  Widget build(BuildContext context) {
    final List<String> tips = ['2', '5', '8','10', '12', LangKeys.otherKey.tr()];
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            'Tip your driver',
            style: AppTextStyles.style16Medium.copyWith(
              color: colors.tertiaryContainer,
            ),
          ),
          5.hSpace,
          AppSelector(
            items: tips,
            initialIndex: 0,
            onChanged: (index) {
              if(index == tips.length-1){
                showTipOtherCounterView = true;
              }
              else{
                showTipOtherCounterView = false;
              }
              setState(() {

              });
            },
            labelColor: colors.onSurface,
            selectedColor: colors.tertiaryContainer,
            radius: 999,
            borderColor: Colors.transparent,
            unselectedColor: Colors.transparent,
          ),
          if(showTipOtherCounterView)FullWidthCounterView(initialValue: 13),
        ],
      ),
    );
  }
}
