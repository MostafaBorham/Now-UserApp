import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class WalletActionButton extends StatelessWidget {
  const WalletActionButton({
    super.key,
    required this.actionName,
    this.onTap,
    this.isSelected = false,
  });

  final String actionName;
  final GestureTapCallback? onTap;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
  onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary500Main
              : colors.neutral500.withValues(alpha: 0.1),
          borderRadius: AppBorderRadius.brCircular30
        ),
        child: Center(child: FittedBox(child: Text(actionName,style: AppTextStyles.style14Medium.copyWith(color: isSelected ? colors.white : colors.black),))),
      ),
    );
  }
}
