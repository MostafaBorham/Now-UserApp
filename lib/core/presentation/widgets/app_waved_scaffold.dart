import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/top_wave_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';

class AppWavedScaffold extends StatelessWidget {
  const AppWavedScaffold({
    super.key,
    required this.body,
    required this.appBarTitle,
    this.appBarActions,
    this.canPop, this.bodyPadding,
  });
  final String appBarTitle;
  final List<Widget>? appBarActions;
  final bool? canPop;
  final Widget body;
  final EdgeInsets? bodyPadding;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Size screenSize = MediaQuery.sizeOf(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 0),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 0.5,
          colors: [
            colors.onSecondaryFixed.withValues(alpha: 0.7), // Center
            colors.onSecondaryFixed, // Edge
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          spacing: 12,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: canPop ?? context.canPop()
                          ? InkWell(
                              onTap: () => context.pop(),
                              child: ReverseWidget(
                                applyReverse: context.isRTL,
                                child: CircleAvatar(
                                  backgroundColor: colors.onPrimary,
                                  radius: screenSize.width * 0.05,
                                  child: Center(
                                    child: Assets.media.images.svg.appBackArrow
                                        .svg(
                                          fit: BoxFit.contain,
                                          width: screenSize.width * 0.05,
                                        ),
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
                        child:
                            appBarActions != null && appBarActions!.isNotEmpty
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
              child: ClipPath(
                clipper: TopWaveClipper(),
                child: Container(
                  padding: bodyPadding?? EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 57,
                  ).copyWith(bottom: 0),
                  decoration: BoxDecoration(
                    color: colors.onPrimary,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, -8), // Shadow to the top
                      ),
                    ],
                  ),
                  child: body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
