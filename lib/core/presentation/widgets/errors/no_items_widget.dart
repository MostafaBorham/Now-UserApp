import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class NoItemsWidget extends StatelessWidget {
  const NoItemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Center(
      // FittedBox lets the empty state shrink instead of overflowing when it
      // gets less height than its content (e.g. while a NestedScrollView body
      // is still being revealed by scrolling).
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.media.images.svg.noItemsIcon.svg(fit: BoxFit.contain,width: MediaQuery.sizeOf(context).width*0.5),
            Text(LangKeys.noItemsYetKey.tr(),style: AppTextStyles.style24SemiBold.copyWith(
              color: colors.onSecondary,
              fontSize: MediaQuery.sizeOf(context).width*0.04
            ),)
          ],
        ),
      ),
    );
  }
}
