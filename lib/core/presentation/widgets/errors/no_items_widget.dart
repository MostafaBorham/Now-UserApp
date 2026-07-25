import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class NoItemsWidget extends StatelessWidget {
  const NoItemsWidget({super.key, this.isScrollable = false, this.emptyMessage});

  /// When `true` the empty state is wrapped in an always-scrollable viewport
  /// that fills the available height, so a wrapping [RefreshIndicator] (or any
  /// pull gesture) still works even though there is no list to scroll.
  final bool? isScrollable;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Widget content = Center(
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
            Text(emptyMessage?? LangKeys.noItemsYetKey.tr(),style: AppTextStyles.style24SemiBold.copyWith(
              color: colors.onSecondary,
              fontSize: MediaQuery.sizeOf(context).width*0.04
            ),)
          ],
        ),
      ),
    );

    if (!isScrollable!) return content;

    // Stretch a scrollable to the full viewport height so the centered content
    // stays centered while still giving the pull-to-refresh gesture something
    // to grab onto.
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
