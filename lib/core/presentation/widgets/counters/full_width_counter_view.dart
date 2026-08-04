import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';


class FullWidthCounterView extends StatefulWidget {
  const FullWidthCounterView({
    super.key,
    required this.initialValue, this.onValueChanged,
  });

  final int initialValue;
  final Function(int)? onValueChanged;

  @override
  State<FullWidthCounterView> createState() => _FullWidthCounterViewState();
}

class _FullWidthCounterViewState extends State<FullWidthCounterView> {
  late int currentValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentValue = widget.initialValue;
  }
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.onSurface.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              if(currentValue>0) currentValue--;
              widget.onValueChanged?.call(currentValue);
              setState(() {

              });
            },
            child: Icon(
              size: 20,
              Icons.remove,
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            '$currentValue',
            style: AppTextStyles.style14Regular.copyWith(
              color: colors.tertiaryContainer,
            ),
          ),
          InkWell(
            onTap: () {
               currentValue++;
              widget.onValueChanged?.call(currentValue);
              setState(() {

              });
            },
            child: Icon(
              size: 20,
              Icons.add,
              color: colors.onSecondary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}