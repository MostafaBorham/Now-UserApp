import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class NoResultsWidget extends StatelessWidget {
  const NoResultsWidget({
    super.key,
    this.isScrollable = false,
    this.emptyMessage,
    this.image,
    this.alignTop = false,
  });
  final bool? isScrollable;
  final String? emptyMessage;

  /// Replaces the default no-results illustration.
  final Widget? image;

  /// Pins the content near the top instead of centring it. For empty states
  /// under a tall header (store details, favourites), where centring in the
  /// leftover space pushed it to the bottom of the screen.
  final bool alignTop;

  static const double _topGap = 40;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Widget column = FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        spacing: 5,
        mainAxisSize: MainAxisSize.min,
        children: [
          image ?? Assets.media.images.svg.noSearchResultIcon.svg(),
          Text(
            emptyMessage ?? LangKeys.noResultFoundKey.tr(),
            style: AppTextStyles.style24SemiBold.copyWith(color: colors.black),
          ),
        ],
      ),
    );
    final Widget content = alignTop
        ? Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: _topGap),
              child: column,
            ),
          )
        : Center(child: column);

    if (!isScrollable!) return content;

    // The bottom inset keeps the content clear of the main shell's floating
    // nav bar (its tabs extend the body under it).
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: bottomInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - bottomInset).clamp(
                0,
                double.infinity,
              ),
            ),
            child: content,
          ),
        );
      },
    );
  }
}
