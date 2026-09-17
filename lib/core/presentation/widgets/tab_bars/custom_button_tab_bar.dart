import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class CustomButtonTabBar extends StatefulWidget {
  const CustomButtonTabBar({
    super.key,
    required this.tabs,
    required this.views,
    this.selectedTabColor,
    required this.unSelectedTabColor,
    this.filterWidget,
    this.selectedLabelColor,
    this.unSelectedLabelColor,
    this.onTap,
    this.selectedIndex,
  });

  final List<String> tabs;
  final List<Widget> views;

  final int? selectedIndex;

  final Color? selectedTabColor;
  final ValueChanged<int>? onTap;
  final Color? selectedLabelColor;
  final Color? unSelectedLabelColor;
  final Color unSelectedTabColor;
  final Widget? filterWidget;

  @override
  State<CustomButtonTabBar> createState() => _CustomButtonTabBarState();
}

class _CustomButtonTabBarState extends State<CustomButtonTabBar>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void didUpdateWidget(covariant CustomButtonTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final int? target = widget.selectedIndex;
    if (target != null &&
        target != _controller.index &&
        target >= 0 &&
        target < _controller.length) {
      _controller.animateTo(target);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context, con) {
        return Column(
          spacing: 16,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 5,
              children: [
                Flexible(
                  child: AnimatedBuilder(
                    animation: _controller.animation ?? _controller,
                    builder: (context, _) => TabBar(
                      controller: _controller,
                      onTap: widget.onTap,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      padding: EdgeInsets.zero,
                      indicator: const BoxDecoration(),
                      dividerHeight: 0,
                      splashFactory: NoSplash.splashFactory,
                      dividerColor: Colors.transparent,
                      overlayColor: WidgetStateProperty.resolveWith(
                        (states) => Colors.transparent,
                      ),
                      labelPadding: EdgeInsets.zero,
                      tabs: List.generate(widget.tabs.length, (index) {
                        final isSelected = _controller.index == index;

                        return Tab(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: EdgeInsetsDirectional.only(
                              start: index == 0 ? 0 : 12,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: AppBorderRadius.brCircular20,
                              color: isSelected
                                  ? widget.selectedTabColor ??
                                        colors.primary500Main
                                  : widget.unSelectedTabColor,
                            ),
                            child: Text(
                              widget.tabs[index],
                              maxLines: 1,
                              style: AppTextStyles.style16Medium.copyWith(
                                fontSize: con.maxWidth * 0.04,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? widget.selectedLabelColor ?? colors.white
                                    : widget.unSelectedLabelColor ??
                                          colors.black,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                widget.filterWidget ?? 0.wSpace,
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _controller,
                viewportFraction: 1,
                physics: const NeverScrollableScrollPhysics(),
                children: widget.views,
              ),
            ),
          ],
        );
      },
    );
  }
}
