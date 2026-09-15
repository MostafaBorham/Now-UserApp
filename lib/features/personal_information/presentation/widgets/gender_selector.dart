import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';




















class CommonScreenTabs extends StatefulWidget {
  const CommonScreenTabs({
    super.key,
    required this.tabsName,
    required this.onTaptab,
    this.icons,
    this.margin = 0,
    this.radius,
    this.tapRadius,
    this.activeFontColor,
    this.padding,
    this.inactiveFontColor,
    this.height = 40,
    this.initialIndex = 0,
    this.activeColor,
    this.backgroundColor,
    this.iconSize = 20,
  }) : assert(
         icons == null || icons.length == tabsName.length,
         'icons must have the same length as tabsName',
       );

  final List<String> tabsName;



  final List<String>? icons;

  final double margin;
  final double? radius;
  final double? height;
  final double? tapRadius;
  final Function(int currentTab) onTaptab;
  final Color? inactiveFontColor;
  final Color? activeFontColor;
  final EdgeInsetsDirectional? padding;


  final int initialIndex;


  final Color? activeColor;



  final Color? backgroundColor;


  final double iconSize;

  @override
  State<CommonScreenTabs> createState() => _CommonScreenTabsState();
}

class _CommonScreenTabsState extends State<CommonScreenTabs> {
  late List<bool> taps;

  @override
  void initState() {
    taps = List.generate(
      widget.tabsName.length,
      (index) => index == widget.initialIndex,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color activeFont = widget.activeFontColor ?? colors.white;
    final Color inactiveFont =
        widget.inactiveFontColor ?? colors.primary500Main;

    return Container(
      width: double.maxFinite,
      height: widget.height,
      padding: widget.padding,
      margin: EdgeInsetsDirectional.symmetric(horizontal: widget.margin),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colors.onPrimaryContainer,
        borderRadius: BorderRadiusDirectional.circular(widget.radius ?? 100),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => ToggleButtons(
          constraints: BoxConstraints.expand(
            width: constraints.maxWidth / taps.length,
          ),
          isSelected: taps,
          renderBorder: false,
          selectedColor: Colors.transparent,
          splashColor: Colors.transparent,
          fillColor: Colors.transparent,
          onPressed: (index) {
            setState(() {
              for (int tapIndex = 0; tapIndex < taps.length; tapIndex++) {
                taps[tapIndex] = tapIndex == index;
              }
            });
            widget.onTaptab(index);
          },
          children: [
            ...List.generate(widget.tabsName.length, (index) {
              final bool selected = taps.elementAt(index);
              final Color foreground = selected ? activeFont : inactiveFont;
              return Container(
                alignment: AlignmentDirectional.center,
                key: ValueKey<bool>(selected),
                margin: const EdgeInsetsDirectional.symmetric(
                  vertical: 4,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.circular(
                    widget.tapRadius ?? 8,
                  ),
                  color: selected
                      ? (widget.activeColor ?? colors.primary500Main)
                      : null,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icons != null) ...[
                        SvgPicture.asset(
                          widget.icons!.elementAt(index),
                          width: widget.iconSize,
                          height: widget.iconSize,
                          colorFilter: ColorFilter.mode(
                            foreground,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        widget.tabsName.elementAt(index),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
