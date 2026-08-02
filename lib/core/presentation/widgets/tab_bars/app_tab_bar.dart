import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.tabs,
    required this.views,
    required this.selectedTabColor,
    this.tabIcons,
  }) : assert(
         tabIcons == null || tabIcons.length == tabs.length,
         'tabIcons must be null or the same length as tabs',
       );

  final List<String> tabs;
  final List<Widget> views;
  final Color selectedTabColor;

  /// Optional prefix icon for each tab. Pass `null` at an index to omit that
  /// tab's icon while keeping icons on others. Must match `tabs.length` when
  /// provided.
  final List<Widget>? tabIcons;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        spacing: 16,
        children: [
          Container(
            height: 58,
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(29),
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStatePropertyAll(Colors.transparent),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: selectedTabColor,
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: colors.onPrimary,
              labelStyle: AppTextStyles.style14SemiBold,
              unselectedLabelColor: Color(0xFF212121),
              tabs: List.generate(tabs.length, (i) {
                final Widget? prefix = tabIcons?[i];
                return Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      if (prefix != null)
                        Builder(
                          builder: (context) {
                            final Color color =
                                IconTheme.of(context).color ??
                                DefaultTextStyle.of(context).style.color ??
                                colors.onPrimary;
                            return ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                color,
                                BlendMode.srcIn,
                              ),
                              child: prefix,
                            );
                          },
                        ),
                      Text(tabs[i]),
                    ],
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: views
                  .map(
                    (v) => Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5,
                      ),
                      child: v,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
