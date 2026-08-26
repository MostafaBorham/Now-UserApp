import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class NoResultsWidget extends StatelessWidget {
  const NoResultsWidget({super.key, this.isScrollable = false, this.emptyMessage});
  final bool? isScrollable;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Widget content = Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          spacing: 5,
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.media.images.svg.noSearchResultIcon.svg(),
            Text(emptyMessage?? LangKeys.noResultFoundKey.tr(),style: AppTextStyles.style24SemiBold.copyWith(
                color: colors.black
            ),)
          ],
        ),
      ),
    );

    if (!isScrollable!) return content;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: content,
          ),
        );
      },
    );
  }
}
