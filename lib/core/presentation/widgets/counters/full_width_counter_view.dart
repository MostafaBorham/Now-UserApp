import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// A round − / + step button: a 16px glyph on a neutral chip.
class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colors.onPrimaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: colors.tertiaryContainer),
      ),
    );
  }
}

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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.neutral200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: () {
              if (currentValue <= 0) return;
              setState(() => currentValue--);
              widget.onValueChanged?.call(currentValue);
            },
          ),
          Text(
            '$currentValue',
            style: AppTextStyles.style14Regular.copyWith(
              color: colors.tertiaryContainer,
            ),
          ),
          _StepButton(
            icon: Icons.add,
            onTap: () {
              setState(() => currentValue++);
              widget.onValueChanged?.call(currentValue);
            },
          ),
        ],
      ),
    );
  }
}