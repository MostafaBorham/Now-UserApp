import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/scroll_spy/sections_scroll_spy.dart';

class SectionsScrollView extends StatelessWidget {
  const SectionsScrollView({
    super.key,
    required this.scrollSpy,
    required this.sectionsCount,
    required this.sectionBuilder,
    this.spacing = 16,
  });

  final SectionsScrollSpy scrollSpy;
  final int sectionsCount;
  final Widget Function(int section) sectionBuilder;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          controller: scrollSpy.scrollController,
          padding: EdgeInsets.only(bottom: spacing),
          child: Column(
            children: List.generate(
              sectionsCount,
              (section) => Container(
                key: scrollSpy.sectionKey(section),
                constraints: BoxConstraints(
                  minHeight: section == sectionsCount - 1
                      ? math.max(0.0, constraints.maxHeight - spacing)
                      : 0,
                ),
                padding: EdgeInsets.only(top: spacing),
                alignment: AlignmentDirectional.topStart,
                child: sectionBuilder(section),
              ),
            ),
          ),
        );
      },
    );
  }
}
