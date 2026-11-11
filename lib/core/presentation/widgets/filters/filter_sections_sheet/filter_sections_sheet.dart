import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_sections_sheet/widgets/filter_actions.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_sections_sheet/widgets/filter_section_card.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_sections_sheet/widgets/filter_side_bar/filter_side_bar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_sections_sheet/widgets/filter_view_header.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/scroll_spy/sections_scroll_spy.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/scroll_spy/sections_scroll_view.dart';

class FilterSectionsSheet extends StatefulWidget {
  const FilterSectionsSheet({
    super.key,
    required this.titles,
    required this.sectionBuilder,
    this.onApply,
    this.onReset,
  });

  final List<String> titles;
  final Widget Function(int section) sectionBuilder;
  final VoidCallback? onApply;
  final VoidCallback? onReset;

  static Future<void> show(
    BuildContext context, {
    required WidgetBuilder builder,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: builder,
    );
  }

  @override
  State<FilterSectionsSheet> createState() => _FilterSectionsSheetState();
}

class _FilterSectionsSheetState extends State<FilterSectionsSheet> {
  int _selectedSection = 0;
  final Set<int> _collapsedSections = <int>{};

  late final SectionsScrollSpy _sectionsScrollSpy = SectionsScrollSpy(
    onSectionAtTop: _selectSectionAtTop,
  );

  void _selectSection(int index) {
    _selectAndExpandSection(index);
    _sectionsScrollSpy.scrollToSection(index);
  }

  void _selectSectionAtTop(int index) {
    if (index == _selectedSection) return;
    _selectAndExpandSection(index);
  }

  void _selectAndExpandSection(int index) => setState(() {
    _selectedSection = index;
    _collapsedSections.remove(index);
  });

  void _toggleSection(int index) => setState(() {
    if (!_collapsedSections.remove(index)) _collapsedSections.add(index);
  });

  void _apply() {
    widget.onApply?.call();
    context.pop();
  }

  @override
  void dispose() {
    _sectionsScrollSpy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.7,
      margin: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: [
          FilterViewHeader(onClose: () => context.pop()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  FilterSideBar(
                    titles: widget.titles,
                    selectedIndex: _selectedSection,
                    onSelected: _selectSection,
                  ),
                  Expanded(
                    child: SectionsScrollView(
                      scrollSpy: _sectionsScrollSpy,
                      sectionsCount: widget.titles.length,
                      sectionBuilder: (section) => FilterSectionCard(
                        title: widget.titles[section],
                        isExpanded: !_collapsedSections.contains(section),
                        onToggle: () => _toggleSection(section),
                        child: widget.sectionBuilder(section),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          FilterActions(onApply: _apply, onReset: widget.onReset),
        ],
      ),
    );
  }
}
