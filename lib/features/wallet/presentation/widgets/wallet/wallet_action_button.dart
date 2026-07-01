import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';

class WalletActionButton extends StatelessWidget {
  const WalletActionButton({super.key, required this.actionName, this.onTap});

  final String actionName;
  final GestureTapCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
  onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
        decoration: BoxDecoration(
          color: colors.onSurface.withValues(alpha: 0.1),
          borderRadius: AppBorderRadius.brCircular30.r
        ),
        child: Center(child: FittedBox(child: Text(actionName,style: AppTextStyles.style14Medium.copyWith(color: colors.onSecondary),))),
      ),
    );
  }
}
