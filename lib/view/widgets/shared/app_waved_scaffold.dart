import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/home/circular_brand_logo.dart';

import 'buttons/primary_app_prefix_icon_button.dart';
import 'reverse_widget.dart';

class AppWavedScaffold extends StatelessWidget {
  const AppWavedScaffold({
    super.key,
    required this.body,
    required this.appBarTitle,
    this.appBarActions,
    this.canPop = false,
  });
  final String appBarTitle;
  final List<Widget>? appBarActions;
  final bool? canPop;
  final Widget body;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 70),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.onSecondaryFixed, colors.onPrimary, colors.onPrimary],
        ),
      ),
      child: Column(
        spacing: 20,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                SizedBox(
                  width: 48.w,
                  child: canPop == true
                      ? InkWell(
                          onTap: () => Navigator.pop(context),
                          child: CircleAvatar(
                            backgroundColor: colors.onPrimary,
                            radius: 20.r,
                            child: ReverseWidget(
                              child: Assets.media.images.svg.arrowBrokenIcon
                                  .svg(),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                Expanded(
                  child: Center(
                    child: AutoSizeText(
                      appBarTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.style24SemiBold.copyWith(
                        color: colors.onSecondary,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  width: 48.w,
                  child: appBarActions != null && appBarActions!.isNotEmpty
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: appBarActions!,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Assets.media.images.svg.whiteWaveBackground.svg(
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 50.0,
                  ),
                  child: body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
