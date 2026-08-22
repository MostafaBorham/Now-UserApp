import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';

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
  final List<String?> tabs;
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

  int get _realTabCount => widget.tabs.where((t) => t != null).length;

  @override
  void initState() {
    super.initState();
    _controller = _createController(0);
  }

  TabController _createController(int initialIndex) {
    final int length = _realTabCount;
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
    final int oldRealCount = oldWidget.tabs.where((t) => t != null).length;
    if (oldRealCount != _realTabCount) {
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
        final double fontSize = con.maxWidth * 0.04;
        return Column(
          spacing: 16,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 5,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(widget.tabs.length, (index) {
                        final String? label = widget.tabs[index];
                        if (label == null) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: AppShimmer(
                              child: Container(
                                width: 70,
                                height: fontSize + 16,
                                decoration: BoxDecoration(
                                  borderRadius: AppBorderRadius.brCircular20,
                                  color: widget.unSelectedTabColor,
                                ),
                              ),
                            ),
                          );
                        }
                        final int realIndex = widget.tabs
                            .take(index + 1)
                            .where((t) => t != null)
                            .length - 1;
                        final bool isSelected =
                            _controller.index == realIndex;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: () {
                              _controller.animateTo(realIndex);
                              widget.onTap?.call(realIndex);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
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
                                label,
                                maxLines: 1,
                                style: AppTextStyles.style16Medium.copyWith(
                                  fontSize: fontSize,
                                  color: isSelected
                                      ? widget.selectedLabelColor ??
                                            colors.white
                                      : widget.unSelectedLabelColor ??
                                            colors.black,
                                ),
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
