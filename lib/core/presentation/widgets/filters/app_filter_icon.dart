import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/app_filter_view.dart';

class AppFilterIcon extends StatelessWidget {
  const AppFilterIcon({super.key, this.size = 20, this.onTap});
  final double? size;
  final GestureTapCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap:
          onTap ??
          () {
            showModalBottomSheet(
              context: context,
              builder: (context) => AppFilterView(
                categories: [
                  LangKeys.allKey.tr(),
                  'Devices',
                  'Shoes',
                  'Clothing',
                ],
                ratings: ['4.0', '5', '4.5'],
              ),
            );
          },
      child: CircleAvatar(
        backgroundColor: colors.tertiary.withValues(alpha: 0.3),
        radius: size,
        child: Assets.media.images.svg.filterIcon.svg(width: size),
      ),
    );
  }
}
