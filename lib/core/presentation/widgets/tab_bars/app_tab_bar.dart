import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.tabs,
    required this.views,
    required this.selectedTabColor,
  });

  final List<String> tabs;
  final List<Widget> views;

  final Color selectedTabColor;


  @override
  Widget build(BuildContext context) {
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
              overlayColor: WidgetStatePropertyAll(
                Colors.transparent,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: selectedTabColor,
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: Colors.white,
              labelStyle: AppTextStyles.style14SemiBold,
              unselectedLabelColor: Color(0xFF212121),
              tabs: tabs.map((e) => Tab(text: e,),).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: views,
            ),
          ),
        ],
      ),
    );
  }
}