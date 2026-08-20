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
  });
  final List<String> tabs;
  final List<Widget> views;
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
    with TickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _createController(0);
  }

  TabController _createController(int initialIndex) {
    final int length = widget.tabs.length;
    final TabController controller = TabController(
      length: length,
      vsync: this,
      initialIndex: length == 0 ? 0 : initialIndex.clamp(0, length - 1),
    );
    controller.addListener(_onTabChanged);
    return controller;
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant CustomButtonTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The tab count can grow/shrink over the widget's life (e.g. tabs arriving
    // from a provider). Rebuild the controller to the new length in place —
    // keeping the selected tab where possible — so callers never need a
    // ValueKey to force a fresh controller.
    if (oldWidget.tabs.length != widget.tabs.length) {
      final int previousIndex = _controller.index;
      _controller.removeListener(_onTabChanged);
      _controller.dispose();
      _controller = _createController(previousIndex);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
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
                  child: TabBar(
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
                    labelPadding: EdgeInsets.symmetric(horizontal: 6),
                    tabs: List.generate(widget.tabs.length, (index) {
                      final isSelected = _controller.index == index;
                      return Tab(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: AppBorderRadius.brCircular20,
                            color: isSelected
                                ? widget.selectedTabColor?? colors.primary500Main
                                : widget.unSelectedTabColor,
                          ),
                          child: Text(
                            widget.tabs[index],
                            maxLines: 1,
                            style: AppTextStyles.style16Medium.copyWith(
                              fontSize: con.maxWidth * 0.04,
                              color: isSelected
                                  ? widget.selectedLabelColor ??
                                        colors.white
                                  : widget.unSelectedLabelColor ??
                                        colors.black,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                widget.filterWidget ?? 0.wSpace,
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: widget.views
                    .map(
                      (view) => _KeepAliveView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: view,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Keeps a tab's view alive once it has been built, so every [CustomButtonTabBar]
/// loads each view only the first time it is opened and then holds its state in
/// memory — no `ValueKey` needed at the call site.
class _KeepAliveView extends StatefulWidget {
  const _KeepAliveView({required this.child});

  final Widget child;

  @override
  State<_KeepAliveView> createState() => _KeepAliveViewState();
}

class _KeepAliveViewState extends State<_KeepAliveView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
