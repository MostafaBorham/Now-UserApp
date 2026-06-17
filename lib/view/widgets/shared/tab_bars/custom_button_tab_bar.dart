import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../responsive/spacing_extension.dart';
import '../../../styles/app_border_radius.dart';
import '../../../styles/text_styles.dart';

class CustomButtonTabBar extends StatefulWidget {
  const CustomButtonTabBar({
    super.key,
    required this.tabs,
    required this.views,
    required this.selectedTabColor,
    required this.unSelectedTabColor, this.filterWidget, this.selectedLabelColor, this.unSelectedLabelColor,
  }) : assert(tabs.length == views.length, 'Tabs count must equal views count');

  final List<String> tabs;
  final List<Widget> views;

  final Color selectedTabColor;
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

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      spacing: 16,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 5,
          children: [
            TabBar(
              controller: _controller,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: const BoxDecoration(),
              dividerHeight: 0,
              splashFactory: NoSplash.splashFactory,
              dividerColor: Colors.transparent,
              overlayColor: WidgetStateProperty.resolveWith(
                    (states) => Colors.transparent,
              ),
              labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
              tabs: List.generate(widget.tabs.length, (index) {
                final isSelected = _controller.index == index;

                return Tab(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      borderRadius: AppBorderRadius.brCircular20.r,
                      color: isSelected
                          ? widget.selectedTabColor
                          : widget.unSelectedTabColor,
                    ),
                    child: Text(
                      widget.tabs[index],
                      maxLines: 1,
                      style: AppTextStyles.style16Medium.copyWith(
                        color: isSelected ? widget.selectedLabelColor?? colors.onPrimary : widget.unSelectedLabelColor?? colors.onSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ),
            widget.filterWidget??0.wSpace,
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _controller, children: widget.views,),
        ),
      ],
    );
  }
}
