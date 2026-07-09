import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';

/// A pill-shaped segmented control used across the app.
///
/// It started life as the gender toggle (Male / Female) on the Edit
/// Information screen and now also backs the Home / Work / Other selector on
/// the Address Details screen.
///
/// When [icons] is provided, each segment shows a leading icon next to its
/// label. Icons are recolored at runtime — using [activeFontColor] when the
/// segment is selected and [inactiveFontColor] otherwise — via a
/// [ColorFilter], so a single asset renders correctly on both the green
/// (selected) pill and the plain (unselected) background regardless of the
/// color baked into the SVG.
///
/// The track ([backgroundColor]), the selected-pill fill ([activeColor]) and
/// the initially selected tab ([initialIndex]) are all configurable so the
/// same control fits both a grey-tracked toggle and a transparent, brand-green
/// selector.
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

  /// Optional SVG asset path per tab, shown before the label. When provided it
  /// must be the same length as [tabsName].
  final List<String>? icons;

  final double margin;
  final double? radius;
  final double? height;
  final double? tapRadius;
  final Function(int currentTab) onTaptab;
  final Color? inactiveFontColor;
  final Color? activeFontColor;
  final EdgeInsetsDirectional? padding;

  /// Tab selected on first build.
  final int initialIndex;

  /// Fill color of the selected segment. Defaults to [Colors.green].
  final Color? activeColor;

  /// Color of the track behind the segments. Defaults to [AppColors.grey].
  final Color? backgroundColor;

  /// Size of the leading icon when [icons] is provided.
  final double iconSize;

  @override
  State<CommonScreenTabs> createState() => _BookingHistroyScreenTabsState();
}

class _BookingHistroyScreenTabsState extends State<CommonScreenTabs> {
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
    final Color activeFont = widget.activeFontColor ?? const Color(0xffEC5B13);
    final Color inactiveFont =
        widget.inactiveFontColor ?? AppColors.datePillText;

    return Container(
      width: double.maxFinite,
      height: widget.height,
      padding: widget.padding,
      margin: EdgeInsetsDirectional.symmetric(horizontal: widget.margin),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.grey,
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
            for (int tapIndex = 0; tapIndex < taps.length; tapIndex++) {
              taps[tapIndex] = tapIndex == index;
            }
            widget.onTaptab(index);
            setState(() {});
          },
          children: [
            ...List.generate(widget.tabsName.length, (index) {
              final bool selected = taps.elementAt(index);
              final Color foreground = selected ? activeFont : inactiveFont;
              return Container(
                width: double.maxFinite / 2,
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
                  color: selected ? (widget.activeColor ?? Colors.green) : null,
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
