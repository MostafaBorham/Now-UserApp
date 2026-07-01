import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';


class AppWavedScaffold extends StatelessWidget {
  const AppWavedScaffold({
    super.key,
    required this.body,
    required this.appBarTitle,
    this.appBarActions,
    this.canPop,
  });
  final String appBarTitle;
  final List<Widget>? appBarActions;
  final bool? canPop;
  final Widget body;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Size screenSize = MediaQuery.sizeOf(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.onSecondaryFixed, colors.onPrimary, colors.onPrimary],
        ),
      ),
      child: SafeArea(
        child: Column(
          spacing: 20,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: canPop?? Navigator.canPop(context)
                          ? InkWell(
                              onTap: () => Navigator.pop(context),
                              child: CircleAvatar(
                                backgroundColor: colors.onPrimary,
                                radius: screenSize.width*0.05,
                                child: Center(
                                  child: Assets.media.images.svg.appBackArrow
                                      .svg(
                                    fit: BoxFit.contain,
                                    width: screenSize.width*0.05
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        appBarTitle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.style24SemiBold.copyWith(
                          color: colors.onSecondary,
                          // fontSize: screenSize.width*0.06
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: appBarActions != null && appBarActions!.isNotEmpty
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: appBarActions!,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
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
                      fit: BoxFit.fill,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 50.0,
                    ).copyWith(
                      bottom: 0
                    ),
                    child: body,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
